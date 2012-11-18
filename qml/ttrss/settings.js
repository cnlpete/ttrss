//Based on the example code at:
//http://www.developer.nokia.com/Community/Wiki/How-to_create_a_persistent_settings_database_in_Qt_Quick_%28QML%29

function getDatabase() {
     return openDatabaseSync("TTRss", "1.0", "Saved state for TTRss", 1000);
}

// At the start of the application, we can initialize the tables we need if they haven't been created yet
function initialize() {
    var db = getDatabase();
    db.transaction(
        function(tx) {
            // Create the settings table if it doesn't already exist
            // If the table exists, this is skipped
            tx.executeSql('CREATE TABLE IF NOT EXISTS settings(setting TEXT UNIQUE, value TEXT)');
    });
}

// This function is used to write a setting into the database
function set(setting, value) {
    // setting: string representing the setting name (eg: “username”)
    // value: string representing the value of the setting (eg: “myUsername”)
    var db = getDatabase();
    var success = false;

    db.transaction(function(tx) {
        var rs = tx.executeSql('INSERT OR REPLACE INTO settings VALUES (?,?);', [setting,value]);
              //console.log(rs.rowsAffected)
              if (rs.rowsAffected > 0) {
                success = true;
              }
    });
    // The function returns true if it was successful, or false if it wasn't
   return success;
}
// This function is used to retrieve a setting from the database
function get(setting, defaultValue) {
    var db = getDatabase();
    var result = defaultValue;

    db.transaction(function(tx) {
        var rs = tx.executeSql('SELECT value FROM settings WHERE setting=?;', [setting]);
        if (rs.rows.length > 0) {
            result = rs.rows.item(0).value;
    }});

    // The function returns defaultValue if no setting is found
    return result;
}
