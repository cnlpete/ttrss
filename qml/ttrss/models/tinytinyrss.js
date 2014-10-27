/*
 * This file is part of TTRss, a Tiny Tiny RSS Reader App
 * for MeeGo Harmattan and Sailfish OS.
 * Copyright (C) 2012–2014  Hauke Schade
 *
 * TTRss is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * TTRss is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with TTRss; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA or see
 * http://www.gnu.org/licenses/.
 */

if(Qt) {
    Qt.include("dump.js")
    Qt.include("htmlentities.js");
}

/**
 * NOTE
 * The ordering in this file is as follows:
 * - Variables
 * - Functions without any network traffic
 * - Functions with network traffic (beginning with login())
 */

/** @public */
var constants = {
    'categories': {
        'ALL':          -3,
        'LABELS':       -2,
        'SPECIAL':      -1,
        'UNCATEGORIZED': 0
    },
    'feeds': {
        'archived':   0,
        'starred':   -1,
        'published': -2,
        'fresh':     -3,
        'all':       -4,
        'recently':  -6
    }
}

/** @private */
var state = {}

/** @private */
var requestsPending = {}

/** @private */
var responsesPending = {}

/**
 * Sets the initial values of variables state, requestsPending, and
 * responsesPending.  This deletes any former values.
 */
function initState() {
    state = {
        'imageProxy':   '',
        'url':          null,
        'shorturl':     null,
        'username':     null,
        'password':     null,
        'httpauth':     { 'dobasicauth' : false },
        'token':        null,
        'apilevel':     0,
        'showall':      false, // boolean; show all items vs only those unread
        'closeIfEmpty': false, // Should pages close if they have no content to display
        'tracelevel':   1,     // 1 = errors, 2 = key info, 3 = network traffic,
                               // 4 = info, 5 = high detail
        'categorycache':     {},
        'feedcache':         {},
        'categoryfeeds':     {},
        'feeditems':         {},
        'lastcategory':      { 'id': null },
        'lastfeed':          { 'id': null, 'continuation': 0 },
        'lastfeeditem':      { 'feedId': null, 'articleId': null },
        'lastfeeditemunread':{ 'feedId': null, 'articleId': null },
        'lastfeeditemrss':   { 'feedId': null, 'articleId': null },
    };

    requestsPending = {
        'categories':     false,
        'feeds':          false,
        'feeditems':      false,
        'feeditemstar':   false,
        'feeditemunread': false,
        'feeditemrss':    false,
    };

    responsesPending = {
        'token':          false,
        'config':         false,
        'categories':     false,
        'feeds':          false,
        'feeditems':      false,
        'feeditemstar':   false,
        'feeditemunread': false,
        'feeditemrss':    false,
    };
}

/**
 * Logs all messages with a log level less or equal than the defined trace level.
 * @private
 * @param {int} Log level of the message.
 * @param {string} Message to log.
 */
function trace(level, text) {
    if(level <= state['tracelevel']) {
        console.log(text + '\n');
    }
}

/**
 * Sets the proxy used for retrieving images as the silica QML Image currently
 * cannot display images coming from a secure line.
 * @param {string} The proxy used to retrieve images.
 */
function setImageProxy(imageProxy) {
    state['imageProxy'] = imageProxy
}

/**
 * Adds the account login credentials to the state.
 * @param {string} The account's username.
 * @param {string} The account's password.
 * @param {string} The url to the tt-rss server.
 */
function setLoginDetails(username, password, url) {
    state['username'] = username
    state['password'] = password

    if (url.substring(url.length-1) !== "/") {
        url += "/"
    }
    if (url.substring(url.length-4) !== "api/") {
        url += "api/"
    }
    if (url.substring(0,1) !== "h") {
        url = "http://" + url
    }

    state['url'] = url
    state['shorturl'] = url.substring(0, url.length-4)

    trace(2, "api url is " + state['url'])
}

/**
 * Adds the authentication credentials for http basic authentication (RFC 2617)
 * to the state.
 * @param {string} The username for the basic authentication.
 * @param {string} The password for the basic authentication.
 */
function setHttpAuthInfo(username, password) {
    state['httpauth']['username']    = username
    state['httpauth']['password']    = password
    state['httpauth']['dobasicauth'] = true
}

/**
 * @return {boolean} Whether only unread items should be shown.
 */
function getShowAll() {
    return state['showall'];
}

/**
 * @param {boolean} Whether only unread items should be shown.
 */
function setShowAll(showAll) {
    state['showall'] = !!showAll;
}

/**
 * @return {array} Sorted array of categories.
 */
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

/**
 * @param {int} Id of the category.
 * @return {array} Sorted array of feeds.
 */
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

/** @private */
function categorySort(a, b) {
    if (a.order_id === undefined || b.order_id === undefined) {
        return a.id - b.id
    } else {
        return a.order_id - b.order_id
    }
}

/**
 * @param {int} Id of the feed.
 * @return {array} Sorted array of feed items.
 */
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

/** @private */
function dateSort(a, b) {
    if (a.updated === undefined || b.updated === undefined) {
        return b.id - a.id
    } else {
        return b.updated - a.updated
    }
}

/**
 * @param {int} Id of the feed.
 * @return {string} The url to the feed's icon.
 */
function getIconUrl(feedId) {
    switch (feedId) {
    case constants['feeds']['all']:
        return "qrc:///images/ic_all.png"
    case constants['feeds']['fresh']:
        return "qrc:///images/ic_fresh.png"
    case constants['feeds']['archived']:
        return "qrc:///images/ic_archived.png"
    case constants['feeds']['recently']:
        return "qrc:///images/ic_recently.png"
    case constants['feeds']['starred']:
        return "qrc:///images/ic_star_enabled.png"
    case constants['feeds']['published']:
        return "qrc:///images/ic_rss_enabled.png"
    default:
        return state['imageProxy'] + state['shorturl'] + state['icons_url'] + '/'
                + feedId + '.ico'
    }
}

/**
 * Login to ttrss server.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function login(callback) {
    if(responsesPending['token']) {
        return;
    }

    responsesPending['token'] = true
    state['token'] = null

    var params = {
        'op': 'login',
        'user': encodeURIComponent(state['username']),
        'password': state['password']
    }
    networkCall(params, function(http) { process_login(callback, http) })
}

/** @private */
function process_login(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['token'] = false;

    if (!response.successful) {
        trace(1, "Login: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    state['token'] = response.content.session_id;
    state['apilevel'] = response.content.api_level;

    trace(5, "sucessfull login with sid " + state['token']);

    if(state['token'] && !processPendingRequests(callback) && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Get config from server.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function getConfig(callback) {
    if(responsesPending['config']) {
        return;
    }

    // needs to be logged in
    if(!state['token']) {
        processPendingRequests(callback);
        return;
    }

    responsesPending['config'] = true;

    var params = {
        'op': 'getConfig',
        'sid': state['token']
    }

    networkCall(params, function(http) { process_getConfig(callback, http) });
}

/** @private */
function process_getConfig(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['config'] = false;

    if (!response.successful) {
        trace(1, "Get config: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    state['icons_url'] = response.content['icons_url'];

    if(!processPendingRequests(callback) && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Update categories from server.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function updateCategories(callback) {
    if(responsesPending['categories']) {
        return;
    }

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

/** @private */
function process_updateCategories(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['categories'] = false;

    if (!response.successful) {
        trace(1, "Update categories: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    state['categorycache'] = {};

    for(var i = 0; i < response.content.length; i++) {
        var catid = response.content[i].id;
        state['categorycache'][catid] = response.content[i];
    }

    // TODO sort

    if(state['categorycache'] && !processPendingRequests(callback) && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Update the feeds of a category.
 * @param {int} The id of the category whose feeds should be updated.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function updateFeeds(catId, callback) {
    if(responsesPending['feeds']) {
        return
    }

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

/** @private */
function process_updateFeeds(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['feeds'] = false;

    if (!response.successful) {
        trace(1, "Update feeds: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    var catId = state['lastcategory']['id']

    state['categoryfeeds'][catId] = [];
    state['feedcache'] = {};

    for(var i = 0; i < response.content.length; i++) {
        var feedid = response.content[i].id;
        state['categoryfeeds'][catId][i] = feedid;
        state['feedcache'][feedid] = response.content[i];
    }

    if(state['categoryfeeds'][catId] && !processPendingRequests(callback)
            && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Update the items of a feed.
 * @param {int} The id of the feed whose items should be updated.
 * @param {boolean} Indicating if the feed is a category instead.
 * @param {int} Skip this amount of items.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function updateFeedItems(feedId, isCat, continuation, callback) {
    if(responsesPending['feeditems']) {
        return;
    }

    if (state['lastfeed']['id'] !== feedId) {
        state['lastfeed']['id'] = feedId;
        state['lastfeed']['isCat'] = isCat;
        state['lastfeed']['continuation'] = continuation;
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
        'is_cat': isCat,
        'include_attachments': true,
        'show_excerpt': false,
        'show_content': true, // we want the content, so we do not have to load
                              // every article for itself
        'view_mode': (state['showall'] ? 'all_articles' : 'unread'),
        'skip': continuation
    }

    networkCall(params, function(http) { process_updateFeedItems(callback, http) });
}

/** @private */
function process_updateFeedItems(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['feeditems'] = false;

    if (!response.successful) {
        trace(1, "Update feed items: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    var feedId = state['lastfeed']['id']

    state['feeditemcache'] = {};
    state['feeditems'][feedId] = [];
    state['lastfeed']['continuation'] += response.content.length;

    for(var i = 0; i < response.content.length; i++) {
        var feeditemid = response.content[i].id;
        state['feeditems'][feedId][i] = feeditemid;
        state['feeditemcache'][feeditemid] = response.content[i];
    }

    if(state['feeditems'][feedId] && !processPendingRequests(callback)
            && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Mark specified feed as read.
 * @param {int} The id of the feed which should be marked as read.
 * @param {boolean} Indicating if the feed is a category instead.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function catchUp(feedId, isCat, callback) {
    if(responsesPending['catchup']) {
        return;
    }

    // needs to be logged in
    if(!state['token']) {
        processPendingRequests(callback);
        return;
    }

    responsesPending['catchup'] = true;

    var params = {
        'op': 'catchupFeed',
        'sid': state['token'],
        'feed_id': feedId,
        'is_cat': isCat
    }

    networkCall(params, function(http) { process_catchUp(callback, http) });
}

/** @private */
function process_catchUp(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['catchup'] = false;

    if (!response.successful) {
        trace(1, "Catch up: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    if(!processPendingRequests(callback) && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Subcribe to a new feed
 * @param {int} The id of the category the feed should be placed in.
 * @param {string} The url of the feed to subcribe to.
 * @param {function} A callback function with parameter int, which is used for
 *     the status code returned by the operation:
 *     <ul>
 *     <li> -1: ERROR, the communication with the tt-rss server wasn't successful.
 *     <li>  0: OK, the Feed already exists.
 *     <li>  1: OK, the Feed was added.
 *     <li>  2: ERROR, the URL is invalid.
 *     <li>  3: ERROR, the URL content is HTML without any feeds available.
 *     <li>  4: ERROR, the URL content is HTML which contains multiple feeds.
 *     <li>  5: ERROR, the URL content couldn't be downloaded.
 *     <li>  6: ERROR, the URL content is invalid XML.
 *     </ul>
 */
function subscribe(catId, url, callback) {
    if(responsesPending['subscribe']) {
        return;
    }

    // needs to be logged in
    if(!state['token']) {
        processPendingRequests(callback)
        return;
    }

    if (state['apilevel'] < 5 && !processPendingRequests(callback) && callback) {
        callback(0)
    }

    responsesPending['subscribe'] = true

    var params = {
        'op': 'subscribeToFeed',
        'sid': state['token'],
        'category_id': catId,
        'feed_url': url
    }

    networkCall(params, function(http) { process_subscribe(callback, http) });
}

/** @private */
function process_subscribe(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['subscribe'] = false;

    if (!response.successful) {
        trace(1, "Subscribe: " + response.errorMessage);
        if (callback) {
            callback(-1);
        }
        return;
    }

    if(!processPendingRequests(callback) && callback) {
        callback(response.content.status.code);
    }
}

/**
 * Unsubscribe from a feed.
 * @param {int} The id of the feed to unsubcribe from.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function unsubscribe(feedId, callback) {
    if(responsesPending['unsubscribe']) {
        return
    }

    // needs to be logged in
    if(!state['token']) {
        processPendingRequests(callback)
        return
    }

    if (state['apilevel'] < 5 && !processPendingRequests(callback) && callback) {
        callback(0)
    }

    responsesPending['unsubscribe'] = true

    var params = {
        'op': 'unsubscribeFeed',
        'sid': state['token'],
        'feed_id': feedId
    }

    networkCall(params, function(http) { process_unsubscribe(callback, http) });
}

/** @private */
function process_unsubscribe(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['unsubscribe'] = false;

    if (!response.successful) {
        trace(1, "Unsubscribing: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    if(!processPendingRequests(callback) && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Star or unstar an article.
 * @param {int} The id of the article.
 * @param {boolean} True if article should be starred, false if not.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function updateFeedStar(articleId, starred, callback) {
    if(responsesPending['feeditemstar']) {
        return;
    }

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

    networkCall(params, function(http) { process_updateFeedStar(callback, http) });

}

/** @private */
function process_updateFeedStar(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['feeditemstar'] = false;

    if (!response.successful) {
        trace(1, "Update feeditem star: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    if(!processPendingRequests(callback) && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Publish or unpublish an article.
 * @param {int} The id of the article.
 * @param {boolean} True if article should be published, false if unpublished.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function updateFeedRSS(articleId, rss, callback) {
    if(responsesPending['feeditemrss']) {
        return;
    }

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

    networkCall(params, function(http) { process_updateFeedRSS(callback, http) });
}

/** @private */
function process_updateFeedRSS(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['feeditemrss'] = false;

    if (!response.successful) {
        trace(1, "Update feeditem rss: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    if(!processPendingRequests(callback) && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * Mark an article as read or unread.
 * @param {int} The id of the article.
 * @param {boolean} True if article should be marked unread, false if read.
 * @param {function} A callback function with parameters boolean (indicating
 *     success) and string (an optional error message).
 */
function updateFeedUnread(articleId, unread, callback) {
    if(responsesPending['feeditemunread']) {
        return;
    }

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

    networkCall(params, function(http) { process_updateFeedUnread(callback, http) });
}

/** @private */
function process_updateFeedUnread(callback, httpreq) {
    var response = process_readyState(httpreq);

    responsesPending['feeditemunread'] = false;

    if (!response.successful) {
        trace(1, "Update feeditem unread: " + response.errorMessage);
        if (callback) {
            callback(false, response.errorMessage);
        }
        return;
    }

    if(!processPendingRequests(callback) && callback) {
        // This action is complete (as there's no other requests to do)
        // Fire callback saying all ok
        callback(true);
    }
}

/**
 * @private
 * @return {boolean} Whether some pending stuff was found.
 */
function processPendingRequests(callback) {
    trace(4, 'In function processPendingRequests()');
    var foundWork = false;

    if(responsesPending['token']) {
        trace(4, 'token response pending');
        return true;
    }

    if (requestsPending['categories']) {
        trace(4, 'categories request pending');
        foundWork = true;
        if(responsesPending['categories']) {
            return foundWork;
        } else if(!state['token']) {
            //Get the auth token
            login(callback);
        } else {
            updateCategories(callback);
        }

    } else if (requestsPending['feeds']) {
        trace(4, 'feeds request pending');
        foundWork = true;
        if(responsesPending['feeds']) {
            return foundWork;
        } else if(!state['token']) {
            //Get the auth token
            login(callback);
        } else {
            updateFeeds(state['lastcategory']['id'], callback);
        }

    } else if (requestsPending['feeditems']) {
        trace(4, 'feeditems request pending');
        foundWork = true;
        if(responsesPending['feeditems']) {
            return foundWork;
        } if(!state['token']) {
            //Get the auth token
            login(callback);
        } else {
            updateFeedItems(state['lastfeed']['id'],
                            state['lastfeed']['isCat'],
                            state['lastfeed']['continuation'],
                            callback);
        }

    } else if (requestsPending['feeditemstar']) {
        trace(4, 'feeditemstar request pending');
        foundWork = true;
        if(responsesPending['feeditemstar']) {
            return foundWork;
        } else if(!state['token']) {
            //Get the auth token
            login(callback);
        } else {
            updateFeedStar(state['lastfeeditem']['articleId'],
                           state['lastfeeditem']['value'],
                           callback);
        }

    } else if (requestsPending['feeditemunread']) {
        trace(4, 'feeditemunread request pending');
        foundWork = true;
        if(responsesPending['feeditemunread']) {
            return foundWork;
        } else if(!state['token']) {
            //Get the auth token
            login(callback);
        } else {
            updateFeedUnread(state['lastfeeditemunread']['articleId'],
                             state['lastfeeditemunread']['value'],
                             callback);
        }

    } else if (requestsPending['feeditemrss']) {
        trace(4, 'feeditemrss request pending');
        foundWork = true;
        if(responsesPending['feeditemrss']) {
            return foundWork;
        } else if(!state['token']) {
            //Get the auth token
            login(callback);
        } else {
            updateFeedRSS(state['lastfeeditemrss']['articleId'],
                          state['lastfeeditemrss']['value'],
                          callback);
        }
    }

    return foundWork;
}

/** @private */
function networkCall(params, callback) {
    var http = new XMLHttpRequest()

    trace(3, dump(params))

    if (state['httpauth']['dobasicauth']) {
        http.open("POST", state['url'], true,
                  state['httpauth']['username'], state['httpauth']['password'])
    } else {
        http.open("POST", state['url'], true)
    }

    http.setRequestHeader('Content-type','application/json; charset=utf-8')

    http.onreadystatechange = function() {
        if (http.readyState === XMLHttpRequest.HEADERS_RECEIVED) {
            trace(3, "Response Headers -->")
            trace(3, http.getAllResponseHeaders())
        } else if (http.readyState === XMLHttpRequest.DONE) {
            callback(http)
        }
    }

    http.send(JSON.stringify(params))
}

/** @private */
function process_readyState(httpreq) {
    var successful = false
    var errorMessage = null
    var responseObject = null

    if(httpreq.status === 200 && httpreq.responseText
            && httpreq.responseText.length > 2)  {

        responseObject = JSON.parse(httpreq.responseText);

        if (responseObject.status === 0) {
            successful = true
        } else if(responseObject.content.error) {
            errorMessage = "Error: " + responseObject.content.error;
        } else {
            errorMessage = "Error (tt-rss status " + responseObject.status + ")"
        }

    } else {
        errorMessage =  "Error (http status " + httpreq.status + ")"

        if (httpreq.responseText) {
            errorMessage += ": " + httpreq.responseText
        }
    }

    return {
        successful: successful,
        errorMessage: successful ? null : errorMessage,
        content: successful ? responseObject.content : null
    };
}
