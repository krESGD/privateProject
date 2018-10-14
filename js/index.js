/** 하단으로 스크롤시 navbar 배경색을 흰색으로 */
        $(window).scroll(function() {
            if ($(document).scrollTop() > 50) {
                $('nav').addClass('shrink');
            } else {
                $('nav').removeClass('shrink');
            }
        });
        
        
        
        /** 요소 클릭시 부드럽게 이동 */
        $(function() {
            $('a[href*="#"]:not([href="#"])').click(function() {
                if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
                    var target = $(this.hash);
                    target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
                    if (target.length) {
                        $('html, body').animate({
                            scrollTop: (target.offset().top -50)
                        }, 1000);
                        return false;
                    }
                }
            });
        });
        
        function info() {
            window.open('info.html', 'info', "width=800, height=800");
        }