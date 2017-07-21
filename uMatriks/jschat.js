function posmod(x, m) {
    x = x % m;
    if (x < 0) x += m;
    return x;
}

function NameCompletion(userlist_, prefix_) {
    this.userlist = [];
    this.prefix = prefix_.toLowerCase();
    for (var i in userlist_) {
        if (userlist_[i].toLowerCase().startsWith(this.prefix)) {
            this.userlist.push(userlist_[i]);
        }
    }
    this.index = -1;
    this.last_dir = 1;
}

NameCompletion.prototype.get = function(forward) {
    if (this.prefix.length === 0) throw new Error('no_prefix');
    if (this.userlist.length === 0) throw new Error('no_completion');

    var dir = forward ? 1 : -1;
    this.index += dir;

    return this.userlist[posmod(this.index, this.userlist.length)];
};

NameCompletion.prototype.complete = function(forward) {
    return this.get(forward) + ', ';
};

var NickColoring = {
    hashCode: function(str) { // java String#hashCode
        var hash = 0;
        for (var i = 0; i < str.length; i++) {
           hash = str.charCodeAt(i) + ((hash << 5) - hash);
        }
        return hash;
    },

    intToRGB: function(i){
        var c = (i & 0x00FFFFFF)
            .toString(16)
            .toUpperCase();

        return "#" + "00000".substring(0, 6 - c.length) + c;
    },

    get: function(nick) {
        return NickColoring.intToRGB(NickColoring.hashCode(nick));
    }
};


// ---------

function test() {
    function assert_eq(act, exp, msg) {
        if (act != exp) throw new Error('Assertion EQ actual == expected :\n' + act + ' == ' + exp + '\nfailed: ' + msg);
    }

    function assert_throws(fn) {
        var t = true;
        try { fn(); t = false; }
        catch (e) {}
        if (!t) throw new Error('throw expected');
    }

    var n = new NameCompletion(['Albert', 'Alaska', 'Bali', 'Czech'], 'A');
    assert_eq(n.get(true), 'Albert');
    assert_eq(n.get(true), 'Alaska');
    assert_eq(n.get(true), 'Albert');

    var n = new NameCompletion(['Albert', 'Alaska'], 'X');
    assert_throws(function() { n.get(true); });
    assert_throws(function() { n.get(false); });

    var n = new NameCompletion(['Abb', 'Acc', 'Add', 'Aee'], 'A');
    assert_eq(n.get(true), 'Abb');
    assert_eq(n.get(true), 'Acc');
    assert_eq(n.get(false), 'Abb');
    assert_eq(n.get(false), 'Aee');

}

test();

