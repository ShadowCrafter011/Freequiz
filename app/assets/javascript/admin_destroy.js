$( "#delete-button-container" ).on("click", "button", function( event ) {
    let button = $( this );
    
    if (button.data("confirmed")) return;

    button.data("confirmed", "1");
    button.toggleClass("btn-danger");
    button.toggleClass("btn-success");
    button.text("Confirmed");

    if (!allConfirmed()) {
        event.preventDefault();
    }
});

function allConfirmed() {
    let return_val = true;
    $( ".delete-btn" ).each(function() {
        if ($( this ).data("confirmed") != "1") {
            return_val = false;
        }
    });
    return return_val;
}

// document.querySelectorAll(".delete-btn").forEach(button => {
//     button.addEventListener("click", e => {
//         e.preventDefault();
//         const btn = e.target;
//         if (btn.dataset.confirmed) return;

//         btn.classList.toggle("btn-danger");
//         btn.classList.toggle("btn-success");
//         btn.innerText = "Confirmed";
//         btn.dataset.confirmed = 1

//         if (!allConfirmed()) {
//             e.preventDefault();
//         }
//     });
// });