const deleteTrigger = document.getElementById("deleteToastBtn");
const toastDiv = document.getElementById("deleteToast");

deleteTrigger.addEventListener("click", () => {
    const toast = new bootstrap.Toast(toastDiv);
    toast.show();
});