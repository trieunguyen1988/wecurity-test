$(document).ready(function () {
    var navListItems = $('div.setup-panel div a'),
            allWells = $('.setup-content'),
            allNextBtn = $('.nextBtn'),
            allPrevBtn = $('.prevBtn'),
            progressBar = $('.progress');
  
    allWells.hide();
    allWells.first().show();
  
    // navListItems.click(function (e) {
    //     e.preventDefault();
    //     var $target = $($(this).attr('href')),
    //             $item = $(this);
  
    //     if (!$item.hasClass('disabled')) {
    //         navListItems.removeClass('btn-primary').addClass('btn-default');
    //         $item.addClass('btn-primary');
    //         allWells.hide();
    //         $target.show();
    //         $target.find('input:eq(0)').focus();
    //     }
    // });

    var prc_width = 0;
    function changeQuestion(){
        if (total_answer <= total_question){
            $('#total_answer').html(total_answer);
        }
        
        var percent = ( (total_answer - 1) / total_question) * 100;
        percent = Math.round(percent)
        console.log('Answer: ' + total_answer);
        prc_width = percent;
        console.log(prc_width);
        progressBar.find('.progress-bar').css('width', prc_width + '%');
        progressBar.find('.percent_complete').html(prc_width + '%');

    }
    changeQuestion();
    
    allPrevBtn.click(function(){
        var curStep = $(this).closest(".setup-content"),
            curStepBtn = curStep.attr("id"),
            prevStepWizard = curStep.prev();
  
            if(curStep.is(':first-child')){
                console.log('First element');
            }

            curStep.hide();
            prevStepWizard.show();

            total_answer = total_answer - 1;
            changeQuestion();
    });
  
    allNextBtn.click(function(){
        var curStep = $(this).closest(".setup-content"),
            curStepBtn = curStep.attr("id"),
            nextStepWizard = curStep.next(),
            curInputs = curStep.find("input[type='radio']"),
            isValid = true;
        
        
  
        $(".form-group").removeClass("has-error");
        for(var i=0; i<curInputs.length; i++){
            if (!curInputs[i].validity.valid){
                isValid = false;
                $(curInputs[i]).closest(".form-group").addClass("has-error");
            }
        }

        if (isValid){
            total_answer = total_answer + 1;
            changeQuestion();
            if(curStep.is(':last-child')){
                $('#frmQuestion').submit();
            } else {
                curStep.hide();
                nextStepWizard.show();
            }            
        }
    });
  
    // $('div.setup-panel div a.btn-primary').trigger('click');
  });