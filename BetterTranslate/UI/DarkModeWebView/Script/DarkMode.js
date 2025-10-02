//
//  DarkMode.js
//  BetterTranslate
//
//  Created by Yurii Kupratsevych on 01.10.2025.
//

(function() {
  const DARK_MODE_CSS = `
    html { 
      filter: invert(1) hue-rotate(180deg) !important;
    }
    html, body { 
      background-color: #fff; min-height: 100%;
    }
    body { 
      min-height: 100vh;
    }
    img, video, picture, canvas, svg { 
      filter: invert(1) hue-rotate(180deg) !important;
    }
  `;

  let constructableSheet = null;
  let styleTag = null;

  function installWithConstructable() {
    try {
      if (!('adoptedStyleSheets' in document)) return false;
      constructableSheet = new CSSStyleSheet();
      constructableSheet.replaceSync(DARK_MODE_CSS);
      document.adoptedStyleSheets = [...document.adoptedStyleSheets, constructableSheet];
      return true;
    } catch(e) {
      return false;
    }
  }

  function installWithStyleTag() {
    try {
      styleTag = document.createElement('style');
      styleTag.textContent = DARK_MODE_CSS;
      document.documentElement.appendChild(styleTag);
      return true;
    } catch(e) {
      return false;
    }
  }
  
  function enableDarkMode() {
    if (isDarkModeEnabled()) return;
    if (installWithConstructable()) return;
    installWithStyleTag();
  }

  function disableDarkMode() {
    if (constructableSheet && document.adoptedStyleSheets) {
      document.adoptedStyleSheets = document.adoptedStyleSheets.filter(s => s !== constructableSheet);
      constructableSheet = null;
    }
    if (styleTag && styleTag.parentNode) {
      styleTag.parentNode.removeChild(styleTag);
      styleTag = null;
    }
  }
  
  function isDarkModeEnabled() {
    if (constructableSheet && document.adoptedStyleSheets?.includes(constructableSheet)) {
      return true;
    }
    if (styleTag && styleTag.parentNode) {
      return true;
    }
    return false;
  }

  window.DarkMode = {
    enable: enableDarkMode,
    disable: disableDarkMode,
    isEnabled: isDarkModeEnabled
  };

  if (document.documentElement.hasAttribute('enable-dark-mode-on-start')) {
    enableDarkMode();
  }
})();
