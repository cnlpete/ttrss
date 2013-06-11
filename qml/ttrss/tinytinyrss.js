//Copyright Hauke Schade, 2012-2013
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
    'shorturl':         null,
    'url':              null,
    'username':         null,
    'password':         null,
    'httpauth':         { 'dobasicauth' : false },
    'token':            null,
    'apilevel':         0,
    'numStatusUpdates': 0,          //each time the state updates such that the app might want to redisplay we update this (get via getNumStatusUpdates)
    'showall':          false,      //boolean should all items be shown (or only those with unread stuff?)
    'closeIfEmpty':     false,      //Should pages close if they have no content to display
    'tracelevel':       1,          //1 = errors, 2 = key info, 3 = network traffic, 4 info, 5 high detail

    'categorycache':    {},
    'feedcache':        {},
    'categoryfeeds':    {},
    'feeditems':        {},
    'lastcategory':     { 'id': null },
    'lastfeed':         { 'id': null, 'continuation': 0 },
    'lastfeeditem':     { 'feedId': null, 'articleId': null },
    'lastfeeditemunread':{ 'feedId': null, 'articleId': null },
    'lastfeeditemrss':  { 'feedId': null, 'articleId': null },
};

var requestsPending={
    'token'       : false,
    'config'      : false,
    'categories'  : false,
    'feeds'       : false,
    'feeditems'   : false,
    'feeditemstar': false,
    'feeditemunread': false,
    'feeditemrss' : false,
};

var responsesPending={
    'token'       : false,
    'config'      : false,
    'categories'  : false,
    'feeds'       : false,
    'feeditems'   : false,
    'feeditemstar': false,
    'feeditemunread': false,
    'feeditemrss' : false,
};

var constants={
    "categories":{
        "ALL":          -3,
        "LABELS":       -2,
        "SPECIAL":      -1,
        "UNCATEGORIZED": 0
    },
    "feeds": {
        'archived':     0,
        'starred':      -1,
        'published':    -2,
        'fresh':        -3,
        'all':          -4,
        'recently':     -6
    }
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
    if (a.order_id === undefined || b.order_id === undefined)
        return a.id - b.id
    else
        return a.order_id - b.order_id
}

function dateSortInverse(a, b) {
    if (a.updated === undefined || b.updated === undefined)
        return a.id - b.id
    else
        return a.updated - b.updated
}

function dateSort(a, b) {
    if (a.updated === undefined || b.updated === undefined)
        return b.id - a.id
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
    if (url.substring(0,1) !== "h")
        url = "http://" + url;
    state['url'] = url;
    state['shorturl'] = url.substring(0, url.length-4);

    trace(2, "api url is " + url);
}

function setHttpAuthInfo(username, password) {
    state['httpauth']['username'] = username
    state['httpauth']['password'] = password
    state['httpauth']['dobasicauth'] = true
}

function networkCall(params, callback) {
    var http = new XMLHttpRequest();

    trace(3, dump(params))

    if (state['httpauth']['dobasicauth'])
        http.open("POST", state['url'], true, state['httpauth']['username'], state['httpauth']['password']);
    else
        http.open("POST", state['url'], true);

    http.setRequestHeader('Content-type','application/json; charset=utf-8');
    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            trace(3, "Response Headers -->");
            trace(3, http.getAllResponseHeaders());
        }
        else if (http.readyState === XMLHttpRequest.DONE)
            callback(http);
    }
    http.send(JSON.stringify(params));
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
    networkCall(params, function(http) { process_login(callback, http) });
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

function updateConfig(callback) {
    if(responsesPending['config'])
        return;

    // needs to be logged in
    if(!state['token']) {
        requestsPending['config'] = true;
        processPendingRequests(callback);
        return;
    }

    responsesPending['config'] = true;

    var params = {
        'op': 'getConfig',
        'sid': state['token']
    }

    networkCall(params, function(http) { process_updateConfig(callback, http) });
}

function process_updateConfig(callback, httpreq) {
    trace(3, "readystate: "+httpreq.readyState+" status: "+httpreq.status);
    trace(3, "response: "+httpreq.responseText);

    if(httpreq.status === 200)  {
        var responseObject=JSON.parse(httpreq.responseText);
        if (responseObject.status === 0) {
            state['icons_dir'] = responseObject.content['icons_dir'];
            state['icons_url'] = responseObject.content['icons_url'];
            state['num_feeds'] = responseObject.content['num_feeds'];
            state['daemon_is_running'] = responseObject.content['daemon_is_running'];
        }
        else {
            if(responseObject.content.error)
                errorText = "Get Config failed: "+responseObject.content.error;
            else
                errorText = "Get Config failed (received http code: "+http.status+")";
        }
    }
    else {
        trace(1, "Get Config Error: received http code: "+httpreq.status+" full text: "+httpreq.responseText);
        if(callback)
            callback(30, "Get Config Error: received http code: "+httpreq.status+" full text: "+httpreq.responseText);
    }

    responsesPending['config'] = false;

    if(state['icons_dir'])
        if(!processPendingRequests(callback))
            //This action is complete (as there's no other requests to do, fire callback saying all ok
            if(callback)
                callback(0);
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

    networkCall(params, function(http) { process_updateCategories(callback, http) });
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
        return

    state['lastcategory']['id'] = catId

    // needs to be logged in
    if(!state['token']) {
        requestsPending['feeds'] = true;
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

    networkCall(params, function(http) { process_updateFeeds(callback, http) });
}

function process_updateFeeds(callback, httpreq) {
    var catId = state['lastcategory']['id']

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
        'include_attachments': true,
        'show_excerpt': false,
        'show_content': true, // we want the content, so we do not have to load every article for itself
        'view_mode': (state['showall'] ? 'all_articles' : 'unread'),
        'skip': state['lastfeed']['continuation']
    }

    networkCall(params, function(http) { process_updateFeedItems(callback, http) });
}

function process_updateFeedItems(callback, httpreq) {
    var feedId = state['lastfeed']['id']

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
            updateFeedUnread(state['lastfeeditemunread']['articleId'],
                             state['lastfeeditemunread']['value'],
                             callback);
    }
    else if (requestsPending['feeditemrss']) {
        trace(4, 'feeditemrss request pending');
        foundWork = true;
        if(responsesPending['feeditemrss'])
            return foundWork;
        if(!state['token'])
            //Get the auth token
            login(callback);
        else
            updateFeedRSS(state['lastfeeditemrss']['articleId'],
                            state['lastfeeditemrss']['value'],
                            callback);
    }

    return foundWork;
}

function catchUp(feedId, callback) {
    if(responsesPending['catchup'])
        return;

    // needs to be logged in
    if(!state['token']) {
        requestsPending['catchup'] = true;
        processPendingRequests(callback);
        return;
    }

    responsesPending['catchup'] = true;

    var params = {
        'op': 'catchupFeed',
        'sid': state['token'],
        'feed_id': feedId
    }

    networkCall(params, function(http) {
                    if (state['feeditems'][feedId]) {
                        for (var feed = 0; feed < state['feeditems'][feedId].length; feed++)
                            state['feeditemcache'][state['feeditems'][feedId][feed]].unread = false
                    }

                    if (state['feedcache'][feedId]) {
                        var cat_id = state['feedcache'][feedId].cat_id
                        if (state['categorycache'][cat_id])
                            state['categorycache'][cat_id].unread -= state['feedcache'][feedId].unread
                        state['feedcache'][feedId].unread = 0
                    }

                    responsesPending['catchup'] = false;
                    if(!processPendingRequests(callback))
                        if(callback)
                            callback(0); });
}

/**
* 0 - OK, Feed already exists
* 1 - OK, Feed added
* 2 - Invalid URL
* 3 - URL content is HTML, no feeds available
* 4 - URL content is HTML which contains multiple feeds.
* 5 - Couldn't download the URL content.
* 6 - Content is an invalid XML.
*/
function subscribe(catId, url, callback) {
    if(responsesPending['subscribe'])
        return;

    // needs to be logged in
    if(!state['token']) {
        requestsPending['subscribe'] = true;
        state['subscribeurl'] = url
        processPendingRequests(callback)
        return;
    }

    if (state['apilevel'] < 5)
        if(!processPendingRequests(callback))
            if(callback)
                callback(0)

    responsesPending['subscribe'] = true

    var params = {
        'op': 'subscribeToFeed',
        'sid': state['token'],
        'category_id': catId,
        'feed_url': url
    }

    networkCall(params, function(http) {
                    trace(3, "response: "+http.responseText)
                    responsesPending['subscribe'] = false

                    if(http.status === 200)  {
                        var responseObject = JSON.parse(http.responseText);
                        if (responseObject.status === 0) {
                            if(!processPendingRequests(callback))
                                if(callback)
                                    callback(responseObject.content.status.code)
                        }
                    }
                    else
                        if(!processPendingRequests(callback))
                            if(callback)
                                callback(-1)
                })
}

function unsubscribe(feedId, callback) {
    if(responsesPending['unsubscribe'])
        return

    // needs to be logged in
    if(!state['token']) {
        requestsPending['unsubscribe'] = true
        processPendingRequests(callback)
        return
    }

    if (state['apilevel'] < 5)
        if(!processPendingRequests(callback))
            if(callback)
                callback(0)

    responsesPending['unsubscribe'] = true

    var params = {
        'op': 'unsubscribeFeed',
        'sid': state['token'],
        'feed_id': feedId
    }

    networkCall(params, function(http) {
                    trace(3, "response: "+http.responseText)
                    if (state['feedcache'][feedId]) {
                        delete state['feedcache'][feedId]
                    }
                    responsesPending['unsubscribe'] = false;
                    if(!processPendingRequests(callback))
                        if(callback)
                            callback(0); })
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

    networkCall(params, function(http) {
                    state['feeditemcache'][articleId].marked = starred;
                    responsesPending['feeditemstar'] = false;
                    if(!processPendingRequests(callback))
                        if(callback)
                            callback(0); });

}

function updateFeedRSS(articleId, rss, callback) {
    if(responsesPending['feeditemrss'])
        return;

    if (state['lastfeeditemrss']['articleId'] !== articleId) {
        state['lastfeeditemrss']['articleId'] = articleId;
        state['lastfeeditemrss']['value'] = rss;
    }

    // needs to be logged in
    if(!state['token']) {
        requestsPending['feeditemrss'] = true;
        processPendingRequests(callback);
        return;
    }

    responsesPending['feeditemrss'] = true;

    var params = {
        'op': 'updateArticle',
        'sid': state['token'],
        'article_ids': articleId,
        'field': 1,
        'mode': (rss ? 1 : 0)
    }

    networkCall(params, function(http) {
                    state['feeditemcache'][articleId].published = rss;
                    responsesPending['feeditemrss'] = false;
                    if(!processPendingRequests(callback))
                        if(callback)
                            callback(0); });
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

    networkCall(params, function(http) {
                    state['feeditemcache'][articleId].unread = unread;
                    var feed_id = state['feeditemcache'][articleId]['feed_id']
                    if (state['feedcache'][feed_id]) {
                        state['feedcache'][feed_id].unread += (unread?1:-1)
                        var cat_id = state['feedcache'][feed_id].cat_id
                        if (state['categorycache'][cat_id])
                            state['categorycache'][cat_id].unread += (unread?1:-1)
                    }

                    responsesPending['feeditemunread'] = false;
                    if(!processPendingRequests(callback))
                        if(callback)
                            callback(0); });
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

function getFeedItems(feedId, inverse) {
    var retVal = []
    var i = 0
    if (state['feeditems'][feedId]) {
        for (var feed = 0; feed < state['feeditems'][feedId].length; feed++) {
            retVal[i] = state['feeditemcache'][state['feeditems'][feedId][feed]]
            i++
        }
    }
    if (inverse === true)
        retVal.sort(dateSortInverse)
    else
        retVal.sort(dateSort)
    return retVal
}

function getNextFeedId(feedId, articleId) {
    var items = getFeedItems(feedId)

    for(var feeditem = 0; feeditem < items.length; feeditem++) {
        if (items[feeditem].id == articleId) {
            if (feeditem+1 < items.length)
                return items[feeditem+1].id
        }
    }
    return false
}

function getPreviousFeedId(feedId, articleId) {
    var items = getFeedItems(feedId)

    for(var feeditem = 0; feeditem < items.length; feeditem++) {
        if (items[feeditem].id == articleId) {
            if (feeditem-1 >= 0)
                return items[feeditem-1].id
            else
                return false
        }
    }
    return false
}

function getFeedItem(feedId, articleId) {
    if (state['feeditemcache'][articleId])
        return state['feeditemcache'][articleId]
    else
        trace(2, "no cache found")
}

function getIconUrl(feedId) {
    switch (feedId) {
    case constants['feeds']['all']:
    case constants['feeds']['fresh']:
    case constants['feeds']['archived']:
    case constants['feeds']['recently']:
        return ''
        break;
    case constants['feeds']['starred']:
        return "resources/ic_star_enabled.png"
        break;
    case constants['feeds']['published']:
        return "resources/ic_rss_enabled.png"
        break;
    default:
        return state['shorturl'] + state['icons_url'] + '/' + feedId + '.ico'
    }
}
