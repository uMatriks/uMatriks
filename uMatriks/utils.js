function checkForLink(string) {
    if (string.indexOf('https://') !== -1 || string.indexOf('http://') !== -1) {
        var words = string.split(' ');
        for (var i = 0; i < words.length; i++) {
            if (
                    (words[i].indexOf('https://') !== -1 || words[i].indexOf('http://') !== -1) &&
                    words[i].indexOf('href=') === -1
                    ) {
                words[i] = words[i].slice(words[i].indexOf("http"));
                var forbiddenEnd = ":/?#[]@!$&'()*+,;=<>\^`{|}%" + '"';
                for (var j = 0; j < forbiddenEnd.length; j++) {
                    if (i === (words.length - 1) && words[i].charAt(words[i].length - 2) === forbiddenEnd[j]) {
                        words[i] = words[i].slice(0, -2);
                    }
                    else if (words[i].charAt(words[i].length - 1) === forbiddenEnd[j]) {
                        words[i] = words[i].slice(0, -1);
                    }
                }
                var newContent = string.replace(words[i], '<a href="' + words[i] + '">' + words[i] + '</a>');
                //console.log(newContent);
                string = newContent;
            }
        }
        return string;
    }
    // it it is not a link return it unchanged
    return string;
}
