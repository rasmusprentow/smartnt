
// Requirement:
// jQuery postMessage plugin
// benalman.com/projects/jquery-postmessage-plugin/

(function () {
    window.PostenCosFrameResizer = new function () {
        var self = this;

        // Get the parent URL (security for modern browsers, necessity for IE7)
        var parent_url, url_holder = "proxyFrame";

        if (window.postMessage) {
            if (window.location.hash) {
                parent_url = decodeURIComponent(window.location.hash.substring(1));
            }
            else {
                parent_url = "*";
            }
        }
        else {
            if (parent.frames[url_holder]) {
                parent_url = decodeURIComponent(parent.frames[url_holder].location.hash.substring(1));
            }
        }
        
        this.autoResize = function () {
                    
            // For good measure
            jQuery('body').append('<div style="clear:both;"></div>');
        
            // Scroll hack
            jQuery.postMessage({ if_height: 0 }, parent_url);
        
            window.setInterval(function () {
                self.resize();
            }, 200);

        };

        function setHeight() {

            var pageHeight = jQuery('body').outerHeight(true);
            
            // The first param is serialized using $.param (if not a string) and passed to the
            // parent window. If window.postMessage exists, the param is passed using that,
            // otherwise it is passed in the location hash (that's why parent_url is required).
            // The second param is the targetOrigin
            jQuery.postMessage({ if_height: pageHeight }, parent_url);

        };

        this.resize = function () {
            setHeight();
        };
    };
})();