(function(win, doc) {
  var url = win.CASino.url('login'),
      cookie_regex = /(^|;)\s*tgt=/,
      ready_bound = false,
      timeout_handle;


  function checkCookieExists() {
    var serviceEl = doc.getElementById('service'),
        service = serviceEl ? serviceEl.getAttribute('value') : null;

    if(cookie_regex.test(doc.cookie)) {
      if(service) {
        url += '?service=' + encodeURIComponent(service);
      }
      win.location = url;
    } else {
      timeout_handle = setTimeout(checkCookieExists, 1000);
    }
  }

  // Auto-login when logged-in in other browser window (9887c4e)
  doc.addEventListener('DOMContentLoaded', function() {
    if(ready_bound) {
      return;
    }
    ready_bound = true;
    var login_form = doc.getElementById('login-form')
    if(login_form) {
      login_form.onsubmit = function() {
        window.clearTimeout(timeout_handle);
      };
      checkCookieExists();
    }
  });

})(this, document);
