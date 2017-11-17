$(document).ready(function () {
    $('.btnLogin').click(function(){
        var username = $('.form-login').find("input[name='username']"),
        password = $('.form-login').find("input[name='password']"),
        isValid = true;
    
        $(".form-group").removeClass("has-error");
        if (!username[0].validity.valid){
            isValid = false;
            $(username[0]).closest(".form-group").addClass("has-error");
        }

        if (!password[0].validity.valid){
            isValid = false;
            $(password[0]).closest(".form-group").addClass("has-error");
        }

        if (isValid){
            $('.form-login').submit();
        }
    });

    $('.form-login').submit(function(){
        $('.btnLogin').trigger('click');
    });
})