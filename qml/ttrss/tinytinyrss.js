//Copyright Hauke Schade, 2012
//
//This file is part of TTRss.
//
//TTRss is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the
//Free Software Foundation, either version 2 of the License, or (at your option) any later version.
//TTRss is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
//MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//You should have received a copy of the GNU General Public License along with TTRss (on a Maemo/Meego system there is a copy
//in /usr/share/common-licenses. If not, see http://www.gnu.org/licenses/.

if(Qt) {
    Qt.include("dump.js")
    Qt.include("htmlentities.js");
}

var state={
    'url':              null,
    'username':         null,
    'password':         null,
    'token':            null,
    'apilevel':         0,
    'numStatusUpdates': 0,          //each time the state updates such that the app might want to redisplay we update this (get via getNumStatusUpdates)
    'showall':          false,      //boolean should all items be shown (or only those with unread stuff?)
    'closeIfEmpty':     false,      //Should pages close if they have no content to display
    'tracelevel':       2,          //1 = errors, 2 = key info, 3 = network traffic, 4 info, 5 high detail

    'categorycache':    {},
    'feedcache':        {},
    'categoryfeeds':    {},
    'feeditems':        {},
    'lastcategory':     { 'id': null },
    'lastfeed':         { 'id': null, 'continuation': 0 },
    'lastfeeditem':     { 'feedId': null, 'articleId': null },
    'lastfeeditemunread':{ 'feedId': null, 'articleId': null },
};

var requestsPending={
    'token'       : false,
    'categories'  : false,
    'feeds'       : false,
    'feeditems'   : false,
    'feeditemstar': false,
    'feeditemunread': false,
};

var responsesPending={
    'token'       : false,
    'categories'  : false,
    'feeds'       : false,
    'feeditems'   : false,
    'feeditemstar': false,
    'feeditemunread': false,
};

var constants={
    "ALL_CATEGORIES": -3,
    "SPECIAL_CATEGORIES": -1,
}

//Clone the initial state so we can clear the state by recloning...
var initial_state            = JSON.parse(JSON.stringify(state));
var initial_requestsPending  = JSON.parse(JSON.stringify(requestsPending));
var initial_responsesPending = JSON.parse(JSON.stringify(responsesPending));

function isEmpty(obj) {
    for(var prop in obj) {
        if(obj.hasOwnProperty(prop))
            return false;
    }

    return true;
}

function trace(level, text) {
    if(level <= state['tracelevel'])
        console.log(text+'\n');
}

function categorySort(a, b) {
    if (!a.order_id && !b.order_id)
        return a.id - b.id
    else if (!a.order_id)
        return a.id - b.order_id
    else if (!b.order_id)
        return a.order_id - b.id
    else
        return a.order_id - b.order_id
}

function dateSort(a, b) {
    if (!a.updated && !b.updated)
        return b.id - a.id
    else if (!a.updated)
        return b.updated - a.id
    else if (!b.updated)
        return b.id - a.updated
    else
        return b.updated - a.updated
}

function clearState() {
    state            = JSON.parse(JSON.stringify(initial_state));
    requestsPending  = JSON.parse(JSON.stringify(initial_requestsPending));
    responsesPending = JSON.parse(JSON.stringify(initial_responsesPending));

    trace(2, "State Cleared");
}

function setLoginDetails(username, password, url) {
    state['username'] = username;
    state['password'] = password;
    if (url.substring(url.length-1) !== "/")
        url += "/";
    if (url.substring(url.length-4) !== "api/")
        url += "api/";
    state['url']      = url;

    trace(2, "api url is " + url);
}

function login(callback) {
    if(responsesPending['token'])
        return;
    responsesPending['token'] = true;
    state['token'] = null;

    var params = {
        'op': 'login',
        'user': encodeURIComponent(state['username']),
        'password': encodeURIComponent(state['password'])
    }

    var http = new XMLHttpRequest();
    http.open("POST", state['url'], true);
    http.setRequestHeader('Content-type','application/json; charset=utf-8');
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            trace(3, "Response Headers -->");
            trace(3, http.getAllResponseHeaders());
        }
        else if (http.readyState === XMLHttpRequest.DONE)
            process_login(callback, http);
    }
    http.send(JSON.stringify(params));
}

function process_login(callback, http) {
    trace(3, "readystate: "+http.readyState+" status: "+http.status);
    trace(3, "response: "+http.responseText);

    var errorText;
    if( http.responseText.length > 2 && http.status === 200 )  {
        var responseObject = JSON.parse(http.responseText);
        if(responseObject.status === 0) {
            state['token'] = responseObject.content.session_id;
            state['apilevel'] = responseObject.content.api_level;
            trace(5,"sucessfull login with sid "+state['token']);
        }
        else {
            trace(1, "Login failed "+http.responseText+" http status: "+http.status);

            if(responseObject.content.error)
                errorText = "Login failed: "+responseObject.content.error;
            else
                errorText = "Login failed (received http code: "+http.status+")";
        }
    }
    else {
        trace(1, "Login Error: received http code: "+http.status+" full text: "+http.responseText);

        if(http.responseText)
            errorText = "Login Error: "+http.responseText+" (received http code: "+http.status+")";
        else
            errorText = "Login failed (received http code: "+http.status+")";
    }

    responsesPending['token'] = false;
    if (state['token']) {
        if(!processPendingRequests(callback))
            //No other things to do, this action is done, fire callback saying ok
            callback(0);
    }
    else
        callback(10, errorText);
}

function updateCategories(callback) {
    if(responsesPending['categories'])
        return;

    // needs to be logged in
    if(!state['token']) {
        requestsPending['categories'] = true;
        processPendingRequests(callback);
        return;
    }

    responsesPending['categories'] = true;

    var params = {
        'op': 'getCategories',
        'sid': state['token'],
        'unread_only': !state['showall']
    }

    var http = new XMLHttpRequest();
    http.open("POST", state['url'], true);
    http.setRequestHeader('Content-type','application/json; charset=utf-8');
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            trace(3, "Response Headers -->");
            trace(3, http.getAllResponseHeaders());
        }
        else if (http.readyState === XMLHttpRequest.DONE)
            process_updateCategories(callback, http);
    }
    http.send(JSON.stringify(params));
}

function process_updateCategories(callback, httpreq) {
    trace(3, "readystate: "+httpreq.readyState+" status: "+httpreq.status);
    trace(3, "response: "+httpreq.responseText);

    if(httpreq.status === 200)  {
        var responseObject=JSON.parse(httpreq.responseText);
        if (responseObject.status === 0) {
            state['categorycache'] = {};

            for(var i = 0; i < responseObject.content.length; i++) {
                var catid = responseObject.content[i].id;
                state['categorycache'][catid] = responseObject.content[i];
            }
            // TODO sort
        }
        else {
            if(responseObject.content.error)
                errorText = "Update Categories failed: "+responseObject.content.error;
            else
                errorText = "Update Categories failed (received http code: "+http.status+")";
        }
    }
    else {
        trace(1, "Update Categories Error: received http code: "+httpreq.status+" full text: "+httpreq.responseText);
        if(callback)
            callback(30, "Update Categories Error: received http code: "+httpreq.status+" full text: "+httpreq.responseText);
    }

    responsesPending['categories'] = false;

    if(state['categorycache'])
        if(!processPendingRequests(callback))
            //This action is complete (as there's no other requests to do, fire callback saying all ok
            if(callback)
                callback(0);
}

function updateFeeds(catId, callback) {
    if(responsesPending['feeds'])
        return;

    // needs to be logged in
    if(!state['token']) {
        requestsPending['feeds'] = true;
        state['lastcategory']['id'] = catId;
        processPendingRequests(callback);
        return;
    }

    responsesPending['feeds'] = true;

    var params = {
        'op': 'getFeeds',
        'sid': state['token'],
        'cat_id': catId,
        'unread_only': !state['showall']
    }

    var http = new XMLHttpRequest();
    http.open("POST", state['url'], true);
    http.setRequestHeader('Content-type','application/json; charset=utf-8');
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            trace(3, "Response Headers -->");
            trace(3, http.getAllResponseHeaders());
        }
        else if (http.readyState === XMLHttpRequest.DONE)
            process_updateFeeds(catId, callback, http);
    }
    http.send(JSON.stringify(params));
}

function process_updateFeeds(catId, callback, httpreq) {
    trace(3, "readystate: "+httpreq.readyState+" status: "+httpreq.status);
    trace(3, "response: "+httpreq.responseText);

    if(httpreq.status === 200)  {
        var responseObject=JSON.parse(httpreq.responseText);
        if (responseObject.status === 0) {
            state['feedcache'] = {};
            state['categoryfeeds'][catId] = [];

            for(var i = 0; i < responseObject.content.length; i++) {
                var feedid = responseObject.content[i].id;
                state['categoryfeeds'][catId][i] = feedid;
                state['feedcache'][feedid] = responseObject.content[i];
            }
        }
        else {
            if(responseObject.content.error)
                errorText = "Update Feeds failed: "+responseObject.content.error;
            else
                errorText = "Update Feeds failed (received http code: "+http.status+")";
        }
    }
    else {
        trace(1, "Update Feeds Error: received http code: "+httpreq.status+" full text: "+httpreq.responseText);
        if(callback)
            callback(40, "Update Feeds Error: received http code: "+httpreq.status+" full text: "+httpreq.responseText);
    }

    responsesPending['feeds'] = false;

    if(state['categoryfeeds'][catId])
        if(!processPendingRequests(callback))
            //This action is complete (as there's no other requests to do, fire callback saying all ok
            if(callback)
                callback(0);
}

function updateFeedItems(feedId, callback) {
    if(responsesPending['feeditems'])
        return;

    if (state['lastfeed']['id'] !== feedId) {
        state['lastfeed']['id'] = feedId;
        state['lastfeed']['continuation'] = 0;
    }

    // needs to be logged in
    if(!state['token']) {
        requestsPending['feeditems'] = true;
        processPendingRequests(callback);
        return;
    }

    responsesPending['feeditems'] = true;

    var params = {
        'op': 'getHeadlines',
        'sid': state['token'],
        'feed_id': feedId,
        'is_cat': false,
        'show_excerpt': false,
        'show_content': true, // we want the content, so we do not have to load every article for itself
        'view_mode': (state['showall'] ? 'all_articles' : 'unread'),
        'skip': state['lastfeed']['continuation']
    }

    var http = new XMLHttpRequest();
    http.open("POST", state['url'], true);
    http.setRequestHeader('Content-type','application/json; charset=utf-8');
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            trace(3, "Response Headers -->");
            trace(3, http.getAllResponseHeaders());
        }
        else if (http.readyState === XMLHttpRequest.DONE)
            process_updateFeedItems(feedId, callback, http);
    }
    http.send(JSON.stringify(params));
}

function process_updateFeedItems(feedId, callback, httpreq) {
    trace(3, "readystate: "+httpreq.readyState+" status: "+httpreq.status);
    trace(3, "response: "+httpreq.responseText);

    if(httpreq.status === 200)  {
        var responseObject=JSON.parse(httpreq.responseText);
        if (responseObject.status === 0) {
            state['feeditemcache'] = {};
            state['feeditems'][feedId] = [];

            //TODO update the continuation counter

            for(var i = 0; i < responseObject.content.length; i++) {
                var feeditemid = responseObject.content[i].id;
                state['feeditems'][feedId][i] = feeditemid;
                state['feeditemcache'][feeditemid] = responseObject.content[i];
            }
        }
        else {
            if(responseObject.content.error)
                errorText = "Update Feeds failed: "+responseObject.content.error;
            else
                errorText = "Update Feeds failed (received http code: "+http.status+")";
        }
    }
    else {
        trace(1, "Update Feeds Error: received http code: "+httpreq.status+" full text: "+httpreq.responseText);
        if(callback)
            callback(50, "Update Feeds Error: received http code: "+httpreq.status+" full text: "+httpreq.responseText);
    }

    responsesPending['feeditems'] = false;

    if(state['feeditems'][feedId])
        if(!processPendingRequests(callback))
            //This action is complete (as there's no other requests to do, fire callback saying all ok
            if(callback)
                callback(0);
}

function processPendingRequests(callback) {
    trace(4, 'In pPR');
    var foundWork = false;

    if(requestsPending['token']) {
        trace(4, 'token request pending');
        foundWork = true;
        if(responsesPending['token'])
            return foundWork;
        //Start the login process
        login(callback);
    }
    else if (requestsPending['categories']) {
        trace(4, 'categories request pending');
        foundWork = true;
        if(responsesPending['categories'])
            return foundWork;
        if(!state['token'])
            //Get the auth token
            login(callback);
        else
            updateCategories(callback);
    }
    else if (requestsPending['feeds']) {
        trace(4, 'feeds request pending');
        foundWork = true;
        if(responsesPending['feeds'])
            return foundWork;
        if(!state['token'])
            //Get the auth token
            login(callback);
        else
            updateFeeds(state['lastcategory']['id'], callback);
    }
    else if (requestsPending['feeditems']) {
        trace(4, 'feeditems request pending');
        foundWork = true;
        if(responsesPending['feeditems'])
            return foundWork;
        if(!state['token'])
            //Get the auth token
            login(callback);
        else
            updateFeedItems(state['lastfeed']['id'], callback);
    }
    else if (requestsPending['feeditemstar']) {
        trace(4, 'feeditemstar request pending');
        foundWork = true;
        if(responsesPending['feeditemstar'])
            return foundWork;
        if(!state['token'])
            //Get the auth token
            login(callback);
        else
            updateFeedStar(state['lastfeeditem']['articleId'],
                           state['lastfeeditem']['value'],
                           callback);
    }
    else if (requestsPending['feeditemunread']) {
        trace(4, 'feeditemunread request pending');
        foundWork = true;
        if(responsesPending['feeditemunread'])
            return foundWork;
        if(!state['token'])
            //Get the auth token
            login(callback);
        else
            updateFeedUnrad(state['lastfeeditemunread']['articleId'],
                            state['lastfeeditemunread']['value'],
                            callback);
    }

    return foundWork;
}

function updateFeedStar(articleId, starred, callback) {
    if(responsesPending['feeditemstar'])
        return;

    if (state['lastfeeditem']['articleId'] !== articleId) {
        state['lastfeeditem']['articleId'] = articleId;
        state['lastfeeditem']['value'] = starred;
    }

    // needs to be logged in
    if(!state['token']) {
        requestsPending['feeditemstar'] = true;
        processPendingRequests(callback);
        return;
    }

    responsesPending['feeditemstar'] = true;

    var params = {
        'op': 'updateArticle',
        'sid': state['token'],
        'article_ids': articleId,
        'field': 0,
        'mode': (starred ? 1 : 0)
    }

    var http = new XMLHttpRequest();
    http.open("POST", state['url'], true);
    http.setRequestHeader('Content-type','application/json; charset=utf-8');
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            trace(3, "Response Headers -->");
            trace(3, http.getAllResponseHeaders());
        }
        else if (http.readyState === XMLHttpRequest.DONE) {
            state['feeditemcache'][articleId].marked = starred;
            responsesPending['feeditemstar'] = false;
            if(!processPendingRequests(callback))
                if(callback)
                    callback(0);
        }
    }
    http.send(JSON.stringify(params));
}

function updateFeedUnread(articleId, unread, callback) {
    if(responsesPending['feeditemunread'])
        return;

    if (state['lastfeeditemunread']['articleId'] !== articleId) {
        state['lastfeeditemunread']['articleId'] = articleId;
        state['lastfeeditemunread']['value'] = unread;
    }

    // needs to be logged in
    if(!state['token']) {
        requestsPending['feeditemunread'] = true;
        processPendingRequests(callback);
        return;
    }

    responsesPending['feeditemunread'] = true;

    var params = {
        'op': 'updateArticle',
        'sid': state['token'],
        'article_ids': articleId,
        'field': 2,
        'mode': (unread ? 1 : 0)
    }

    var http = new XMLHttpRequest();
    http.open("POST", state['url'], true);
    http.setRequestHeader('Content-type','application/json; charset=utf-8');
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            trace(3, "Response Headers -->");
            trace(3, http.getAllResponseHeaders());
        }
        else if (http.readyState === XMLHttpRequest.DONE) {
            state['feeditemcache'][articleId].unread = unread;
            responsesPending['feeditemunread'] = false;
            if(!processPendingRequests(callback))
                if(callback)
                    callback(0);
        }
    }
    http.send(JSON.stringify(params));
}

//Indicates whether only unread items should be shown
function getShowAll() {
    return state['showall'];
}

//Sets whether only unread items should be shown
function setShowAll(showAll) {
    state['showall'] = !!showAll;
    state['numStatusUpdates']++;
}

function getCloseIfEmpty() {
    return state['closeIfEmpty'];
}

function setCloseIfEmpty(newState) {
    state['closeIfEmpty'] = newState;
}

function getNumStatusUpdates() {
    return state['numStatusUpdates'];
}

function getCategories() {
    var retVal = []
    var i = 0
    for (var cat in state['categorycache']) {
        retVal[i] = state['categorycache'][cat]
        i++
    }
    retVal.sort(categorySort)

    return retVal
}

function getFeeds(catId) {
    var retVal = []
    var i = 0
    if (state['categoryfeeds'][catId]) {
        for (var feed = 0; feed < state['categoryfeeds'][catId].length; feed++) {
            retVal[i] = state['feedcache'][state['categoryfeeds'][catId][feed]]
            i++
        }
    }
    retVal.sort(categorySort)
    return retVal
}

function getFeedItems(feedId) {
    var retVal = []
    var i = 0
    if (state['feeditems'][feedId]) {
        for (var feed = 0; feed < state['feeditems'][feedId].length; feed++) {
            retVal[i] = state['feeditemcache'][state['feeditems'][feedId][feed]]
            i++
        }
    }
    retVal.sort(dateSort)
    return retVal
}

function getFeedItem(feedId, articleId) {
    if (state['feeditemcache'][articleId])
        return state['feeditemcache'][articleId]
    else
        console.log("no cache found")
}
