/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef PANELMODEL_H
#define PANELMODEL_H

#include <QAbstractItemModel>
#include <QList>
//#include <QSignalMapper>

#include <QtDeclarative/QDeclarativeExtensionPlugin>
#include <QtDeclarative/qdeclarative.h>

#include "panelobj.h"

class QFileSystemWatcher;
class QSettings;

class PanelModel : public QAbstractItemModel
{
    Q_OBJECT

public:
    explicit PanelModel(QObject *parent = 0);

    QModelIndex index (int row, int column,
                       const QModelIndex &parent = QModelIndex()) const;

    QModelIndex parent(const QModelIndex &index = QModelIndex()) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    int columnCount(const QModelIndex &parent = QModelIndex()) const;

    QVariant data(const QModelIndex &index, int role) const;

public slots:
    void setInvisible(uint position);
    void makeVisible(uint position);
    void move (uint oldPosition, uint newPosition);

private slots:
    void onDirectoryChanged();
    void onDataChanged(PanelObj* panel);
    bool loadPanels();

private:
    void clearPanelList();

    QList<PanelObj*> mPanelList;

    QFileSystemWatcher *mDesktopFilesWatcher;
    QFileSystemWatcher *mConfWatcher;
    QSettings *mSettings;

};


#endif // PANELMODEL_H
