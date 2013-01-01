var CacheManager = new function() {
    var items = {}, 
        config = {
            max_size: 30
        };

    return {
        insert: function( key, item ) {
            if ( typeof items[ key ] !== "undefined" ) {
            }

            items[ key ] = {
                last_updated: Date.now(),
                entry_value: item
            };

        },
        expire: function( key ) {
            if ( typeof items[ key ] !== "undefined" ) {
                delete items[ key ];
            }
        },
        get: function( key ) {
            var result = items[ key ];
            return (typeof result === "undefined") ? null : result["entry_value"];
        },
        config: function( options ) {

        }
    }
}