let anchor = location.hash;

var anchorElement = $(`[href="${location.pathname}${anchor}"]`);
if (anchorElement != null) {
    anchorElement.addClass("active");
}

let section = document.getElementById(anchor);
if (section != null) {
    window.scrollTo(0, section.offsetTop);
}

$(document).on("click", "div[id='api-nav-links'] a", function(event) {
    let item = $( this );

    location.href = item.attr("href");
            
    if (anchorElement != item) {
        $(".active").each(function( ) {
            $(this).removeClass("active");
        });

        anchorElement = item;
        item.addClass("active");
    }
});

// document.addEventListener("scroll", () => {
//     let highest;
//     for (let section of document.getElementsByClassName("section")) {
//         let rect = section.getBoundingClientRect();

//         if (rect.top < window.innerHeight && rect.bottom > 0) {
//             // If the element is higher than the previous highest element, update the reference
//             if (!highest || rect.bottom > highest.getBoundingClientRect().bottom) {
//                 highest = section;
//             }
//         }
//     }

//     if (anchorElement != highest) {
//         document.querySelectorAll(".link").forEach(element => {
//             element.classList.remove("active");
//         });

//         anchorElement = document.querySelector(`[href="${location.pathname}#${highest.id}"]`);
//         anchorElement.classList.add("active");
//         location.hash = highest.id;
//     }
// });