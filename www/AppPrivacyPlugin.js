const exec = require('cordova/exec');

const AppPrivacyPlugin = {
    enablePrivacyMode: (success = () => {}, error = () => {}) => {
        exec(success, error, 'AppPrivacyPlugin', 'enablePrivacyMode', []);
    },

    disablePrivacyMode: (success = () => {}, error = () => {}) => {
        exec(success, error, 'AppPrivacyPlugin', 'disablePrivacyMode', []);
    }
}

module.exports = AppPrivacyPlugin;