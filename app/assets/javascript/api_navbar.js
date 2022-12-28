let anchor = location.hash;

var anchorElement = document.querySelector(`[href="${location.pathname}${anchor}"]`);
if (anchorElement != null) {
    anchorElement.classList.add("active");
}

let section = document.getElementById(anchor);
if (section != null) {
    window.scrollTo(0, section.offsetTop);
}
    
add_click_listeners();
document.addEventListener("turbo:load", add_click_listeners);

function add_click_listeners() {
    for (let item of document.getElementsByClassName("link")) {
        item.addEventListener("click", e => {
            location.href = item.getAttribute("href");
            
            if (anchorElement != e.target) {
                for (let removeActive of document.getElementsByClassName("active")) {
                    removeActive.classList.remove("active");
                }

                anchorElement = e.target;
                e.target.classList.add("active");
            }
        });
    }
}

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