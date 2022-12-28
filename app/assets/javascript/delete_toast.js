setup_delete_toast();
document.addEventListener("turbo:load", setup_delete_toast);

function setup_delete_toast() {
    const deleteTrigger = document.getElementById("deleteToastBtn");
    const toastDiv = document.getElementById("deleteToast");

    deleteTrigger.addEventListener("click", () => {
        const toast = new bootstrap.Toast(toastDiv);
        toast.show();
    });
}