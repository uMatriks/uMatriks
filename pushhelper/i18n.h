#pragma once

#include <libintl.h>

#include <QString>

const QString GETTEXT_DOMAIN   = "umatriks.larreamikel";

#define _(value) gettext(value)
#define N_(value) gettext(value)
