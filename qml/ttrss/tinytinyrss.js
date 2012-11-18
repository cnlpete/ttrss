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
//    'categoryunread':   null,       //category unread counts (created by updateUnread() )
//    'feedtree':         null,       //feeds arranged by category including unread count (created by makeFeedTree() )
//    'feedlist':         null,       //feeds arranged in an associative array (key = id)
    'numStatusUpdates': 0,          //each time the state updates such that the app might want to redisplay we update this (get via getNumStatusUpdates)
    'showall':          false,      //boolean should all items be shown (or only those with unread stuff?)
    'closeIfEmpty':     false,      //Should pages close if they have no content to display
//    'feedcache':        {},         //as feed items are retrieved they are stored here for re-use
    'tracelevel':       4,          //1 = errors, 2 = key info, 3 = network traffic, 4 info, 5 high detail
};

var requestsPending={
    'token'       : false,
    'categories'  : false,
};

var responsesPending={
    'token'       : false,
    'categories'  : false,
};

var constants={
    "ALL_CATEGORIES": -3,
    "SPECIAL_CATEGORIES": -1,
}

//Clone the initial state so we can clear the state by recloning...
var initial_state            = JSON.parse(JSON.stringify(state));
var initial_requestsPending  = JSON.parse(JSON.stringify(requestsPending));
var initial_responsesPending = JSON.parse(JSON.stringify(responsesPending));

function trace(level, text) {
    if(level <= state['tracelevel'])
        console.log(text+'\n');
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
        'unread_only': false
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
            state['categories'] = {};

            for(var i = 0; i < responseObject.content.length; i++) {
                if (responseObject.content[i].order_id) {
                    var feedid = responseObject.content[i].order_id;
                    trace(4, "Setting feedlist key:"+feedid);
                    state['categories'][feedid] = responseObject.content[i];
                }
                else {
                    // special categories
                    var feedid = responseObject.content[i].id;
                    state['categories'][feedid] = responseObject.content[i];
                }
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

    if(state['categories'])
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

    return foundWork;
}

//Indicates whether only unread items should be shown
function getShowAll() {
    return state['showall'];
}

//Sets whether only unread items should be shown
function setShowAll(showAll) {
    state['showall'] = showAll;
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
    return state['categories'];
}
