
export function redirect(href) {
    location.href = href;
}

export function setDocumentTitle(value) {
    document.title = value;
}

export function localStorageGetString(key) {
    return localStorage.getItem(key) || "";
}

export function localStorageSetString(key, value) {
    return localStorage.setItem(key, value);
}
