/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "panelsplugin.h"
#include "panelobj.h"
#include "panelmodel.h"
#include "panelproxymodel.h"
#include "musicinterface.h"

void panels::registerTypes(const char *uri)
{
    qmlRegisterType<PanelObj>(uri, 0, 1, "PanelObj");
    qmlRegisterType<PanelModel>(uri, 0, 1, "PanelModel");
    qmlRegisterType<PanelProxyModel>(uri, 0, 1, "PanelProxyModel");
    qmlRegisterType<MusicInterface>(uri, 0, 1, "MusicInterface");
}

Q_EXPORT_PLUGIN(panels);

