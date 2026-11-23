(function () {
    'use strict';
    var button = document.getElementById('menuToggle');
    var menu = document.getElementById('menuPrincipal');
    if (!button || !menu) return;
    button.addEventListener('click', function () {
        var open = button.getAttribute('aria-expanded') === 'true';
        button.setAttribute('aria-expanded', String(!open));
        menu.classList.toggle('is-open', !open);
    });
    document.addEventListener('keydown', function (event) {
        if (event.key === 'Escape') {
            menu.classList.remove('is-open');
            button.setAttribute('aria-expanded', 'false');
        }
    });
}());
