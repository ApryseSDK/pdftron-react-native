(function($) {
  var navbarHeight;
  var initialised = false;
  var navbarOffset;

  function elOffset($el) {
    return $el.offset().top - (navbarHeight + navbarOffset);
  }

  function scrollToHash(duringPageLoad) {
    var elScrollToId = location.hash.replace(/^#/, '');
    var $el;

    function doScroll() {
      var offsetTop = elOffset($el);
      window.scrollTo(window.pageXOffset || window.scrollX, offsetTop);
    }

    if (elScrollToId) {
      $el = $(document.getElementById(elScrollToId));

      if (!$el.length) {
        $el = $(document.getElementsByName(elScrollToId));
      }

      if ($el.length) {
        if (duringPageLoad) {
          $(window).one('scroll', function() {
            setTimeout(doScroll, 100);
          });
        } else {
          setTimeout(doScroll, 0);
        }
      }
    }
  }

  function init(opts) {
    if (initialised) {
      return;
    }
    initialised = true;
    navbarHeight = $('.navbar').height();
    navbarOffset = opts.navbarOffset;

    // some browsers move the offset after changing location.
    // also catch external links coming in
    $(window).on("hashchange", scrollToHash.bind(null, false));
    $(scrollToHash.bind(null, true));
  }

  $.catchAnchorLinks = function(options) {
    var opts = $.extend({}, jQuery.fn.toc.defaults, options);
    init(opts);
  };

  $.fn.toc = function(options) {
    var self = this;
    var opts = $.extend({}, jQuery.fn.toc.defaults, options);

    var container = $(opts.container);
    var tocs = [];
    var cats = new Map();
    var headings = $(opts.selectors, container);
    var headingOffsets = [];
    var activeClassName = 'active';
    var ANCHOR_PREFIX = "__anchor";
    var maxScrollTo;
    var visibleHeight;
    var headerHeight = 10; // so if the header is readable, its counted as shown
    init();

    var scrollTo = function(e) {
      e.preventDefault();
      var target = $(e.target);
      if (target.prop('tagName').toLowerCase() !== "a") {
        target = target.parent();
      }
      var elScrollToId = target.attr('href').replace(/^#/, '') + ANCHOR_PREFIX;
      var $el = $(document.getElementById(elScrollToId));

      var offsetTop = Math.min(maxScrollTo, elOffset($el));

      $('body,html').animate({ scrollTop: offsetTop }, 400, 'swing', function() {
        location.hash = '#' + elScrollToId;
      });

      $('a', self).removeClass(activeClassName);
      target.addClass(activeClassName);
    };

    var calcHadingOffsets = function() {
      maxScrollTo = $("body").height() - $(window).height();
      visibleHeight = $(window).height() - navbarHeight;
      headingOffsets = [];
      headings.each(function(i, heading) {
        var anchorSpan = $(heading).prev("span");
        var top = 0;
        if (anchorSpan.length) {
          top = elOffset(anchorSpan);
        }
        headingOffsets.push(top > 0 ? top : 0);
      });
    }

    const getAncestors = function (child, list) {
      const attributes = child[0].attributes;
      const attribLength = attributes.length;
      const hasCategory = attributes.item(attribLength - 2).name.includes("data-in-category");
      let catArray = [];
      const ancestors = [];

      if (hasCategory) {
        catArray = [attributes.item(attribLength - 2).value, attributes.item(attribLength - 1).value];
      } else {
        catArray = [null, attributes.item(attribLength - 1).value];
      }

      catArray.forEach((cat) => {
        if (cat !== null) {
          for (const item of list) {
            if (item[0].attributes.href.value.includes(cat)) {
              ancestors.push(item);
              break;
            }
          }
        }
      });

      return ancestors;
    };

    //highlight on scroll
    var timeout;
    var highlightOnScroll = function(e) {
      if (!tocs.length) {
        return;
      }
      if (timeout) {
        clearTimeout(timeout);
      }
      timeout = setTimeout(function() {
        var top = $(window).scrollTop(),
          highlighted;
        for (var i = headingOffsets.length - 1; i >= 0; i--) {
          var isActive = tocs[i].hasClass(activeClassName);
          // at the end of the page, allow any shown header
          if (isActive && headingOffsets[i] >= maxScrollTo && top >= maxScrollTo) {
            return;
          }
          // if we have got to the first heading or the heading is the first one visible
          if (i === 0 || (headingOffsets[i] + headerHeight >= top && (headingOffsets[i - 1] + headerHeight <= top))) {
            // in the case that a heading takes up more than the visible height e.g. we are showing
            // only the one above, highlight the one above
            if (i > 0 && headingOffsets[i] - visibleHeight >= top) {
              i--;
            }
            $('a', self).removeClass(activeClassName);
            if (i >= 0) {
              highlighted = tocs[i].addClass(activeClassName);
              const ancestors = getAncestors(highlighted, tocs);
              opts.onHighlight(highlighted);
              let style = highlighted[0].attributes.getNamedItem("style");
              if (style !== null) {
                style = style.value;
                if (style.includes("none") === true || ancestors.length !== 2) {
                  ancestors.forEach((ancestor) => {
                    ancestor.addClass(activeClassName);
                    opts.onHighlight(ancestor);
                  });
                }
              } else {
                ancestors.forEach((ancestor) => {
                  ancestor.addClass(activeClassName);
                  opts.onHighlight(ancestor);
                });
              }
            }
            break;
          }
        }
      }, 50);
    };
    if (opts.highlightOnScroll) {
      $(window).bind('scroll', highlightOnScroll);
      $(window).bind('load resize', function() {
        calcHadingOffsets();
        highlightOnScroll();
      });
    }

    var rotateCaret = function(caret) {
      if (caret.style.transform === 'rotate(0deg)') {
        caret.style.transform = 'rotate(-90deg)';
      } else {
        caret.style.transform = 'rotate(0deg)';
      }
    }

    // Add caret to list-group-item if not present
    var prependCaret = function(array) {
      if (array && array[0] && array[0].children.length === 1) {
        var caret = $('<b class="caret"></b>')
          .attr('style', 'transform: rotate(-90deg); opacity: 80%;');
        array[0].prepend(caret[0]);
        return caret[0];
      } 
      return null;
    }

    return this.each(function() {
      //build TOC
      var el = $(this);
      var ul = $('<div class="list-group">');

      var supercat = ''; // Latest super-category (methods/members/events...)
      var category = ''; // Latest category

      headings.each(function(i, heading) {
        var $h = $(heading);

        var anchor = $('<span/>').attr('id', opts.anchorName(i, heading, opts.prefix) + ANCHOR_PREFIX).insertBefore($h);
        
        var span = $('<span/>')
          .text(opts.headerText(i, heading, $h));

        //build TOC item
        var a = $('<a class="list-group-item"/>')
          .append(span)
          .attr('href', '#' + opts.anchorName(i, heading, opts.prefix));

        span.addClass(opts.itemClass(i, heading, $h, opts.prefix));
        span.css('margin-left', '10px');

        switch (opts.itemClass(i, heading, $h, opts.prefix)) {
          case "toc-h2": 
            supercat = opts.anchorName(i, heading, opts.prefix);
            category = '';
            a.attr('data-supercat', supercat)
              .bind('click', function(e) {
                var children = document.querySelectorAll(`[data-in-supercat="${$(this).attr('data-supercat')}"]`);
                Array.from(children).forEach((child) => { 
                  if (child.style.display === "none") {
                    // When opening children of supercategories, avoid
                    // automatically opening children within categories.
                    if (!child.getAttribute('data-in-category')) {
                      child.style.display = "block";
                    }
                  } else {
                    var carets = child.getElementsByTagName("b");
                    if (carets[0]) {
                      carets[0].style.transform = 'rotate(-90deg)';
                    }
                    child.style.display = "none";
                  }
                });
                rotateCaret($(this).find("b")[0]);
                el.trigger('selected', $(this).attr('href'));
              });
            cats.set(supercat, a);
            break;

          case "toc-h3": 
            category = opts.anchorName(i, heading, opts.prefix);
            a.attr('style', 'display: none')
              .attr('data-category', category)
              .attr('data-in-supercat', supercat)
              .bind('click', function(e) {
                var children = document.querySelectorAll(`[data-in-category="${$(this).attr('data-category')}"]`);
                Array.from(children).forEach((child) => { 
                  if ($(this).css('display') !== "none") {
                    if (child.style.display === "none") {
                      child.style.display = "block";
                    } else {
                      child.style.display = "none";
                    }
                  }
                });
                rotateCaret($(this).find("b")[0]);
                el.trigger('selected', $(this).attr('href'));
              });

            var caret = prependCaret( cats.get(supercat) );
            if (caret) caret.style['margin-left'] = '5px';
            cats.set(category, a);
            break;

          case "toc-h4":
            a.attr('style', 'display: none')
              .attr('data-in-category', category)
              .attr('data-in-supercat', supercat)
              .bind('click', function(e) {
                scrollTo(e);
                el.trigger('selected', $(this).attr('href'));
              });

            var caret = prependCaret( cats.get(supercat) );
            if (caret) caret.style['margin-left'] = '5px';
            
            if (category) {
              caret = prependCaret( cats.get(category) );
              if (caret) caret.style['margin-left'] = '14px';
              span.css('margin-left', '40px');
            } else {
              span.css('margin-left', '32px');
            }
            break;
          default:
            category = '';
            a.bind('click', function(e) {
                scrollTo(e);
                el.trigger('selected', $(this).attr('href'));
              });
            span.css('margin-left', '5px');
        }

        tocs.push(a);

        ul.append(a);
      });
      el.html(ul);

      calcHadingOffsets();
    });
};


jQuery.fn.toc.defaults = {
  container: 'body',
  selectors: 'h1,h2,h3',
  smoothScrolling: true,
  prefix: 'toc',
  onHighlight: function() {},
  highlightOnScroll: true,
  navbarOffset: 0,
  anchorName: function(i, heading, prefix) {
    return prefix+i;
  },
  headerText: function(i, heading, $heading) {
    return $heading.text();
  },
  itemClass: function(i, heading, $heading, prefix) {
    return prefix + '-' + $heading[0].tagName.toLowerCase();
  }

};

})(jQuery);
