/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "panelmodel.h"
#include "panelobj.h"

#include <QList>
#include <QDir>
#include <QMetaProperty>
#include <QSettings>
#include <QFileSystemWatcher>
#include <QFileInfo>
#include <QDebug>
#include <QFile>

PanelModel::PanelModel(QObject *parent) :
        QAbstractItemModel(parent)
{

    QHash<int, QByteArray> roles;
    roles.insert(PanelObj::DESKTOPFILENAME, "desktopFileName");
    roles.insert(PanelObj::DISPLAYNAME, "displayName");
    roles.insert(PanelObj::UNIQUENAME, "uniqueName");
    roles.insert(PanelObj::SETTINGSICON, "settingsIcon");
    roles.insert(PanelObj::PATH, "path");
    roles.insert(PanelObj::ALLOWHIDE, "allowHide");
    roles.insert(PanelObj::DEFAULTINDEX, "defaultIndex");
    roles.insert(PanelObj::INDEX, "index");
    roles.insert(PanelObj::VISIBLE, "isVisible");
    roles.insert(PanelObj::PANELOBJ, "panelObj");
    setRoleNames(roles);


    mDesktopFilesWatcher = new QFileSystemWatcher(this);
    mDesktopFilesWatcher->addPath(PANEL_DESKTOP_PATH);

    connect(mDesktopFilesWatcher,
            SIGNAL(directoryChanged(QString)),
            this,
            SLOT(loadPanels()));

    //These are shared amongst all the panels to save memory...
    mSettings = new QSettings(SETTINGS_ORG, SETTINGS_APP, this);
    QFileInfo fi(mSettings->fileName());
    if (!fi.exists()) {
        //This is a bit hacky, but it ensures the file exists before we set a watcher on it...
        QFile file(mSettings->fileName());
        file.open(QIODevice::WriteOnly);
        file.write("\n");
        file.flush();
        file.close();
    }

    mConfWatcher = new QFileSystemWatcher(this);
    mConfWatcher->addPath(mSettings->fileName());

    loadPanels();

}

QModelIndex PanelModel::index(int row, int column, const QModelIndex &parent) const
{
    if (!parent.isValid())
        return createIndex(row, column);
    else
        return QModelIndex();
}


QModelIndex PanelModel::parent(const QModelIndex &index) const
{
    Q_UNUSED(index);
    return QModelIndex();
}


int PanelModel::rowCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return mPanelList.count();
}

int PanelModel::columnCount(const QModelIndex &parent) const
{
    Q_UNUSED(parent);
    return PanelObj::staticMetaObject.propertyCount()
            - PanelObj::staticMetaObject.propertyOffset();
}

QVariant PanelModel::data(const QModelIndex &index, int role) const
{

    if (!index.isValid())
        return QVariant();

    QMetaObject panelMetaObject = PanelObj::staticMetaObject;
    QString propertyName;
    int propertyIndex = panelMetaObject.propertyOffset();


    PanelObj* panel = mPanelList.at(index.row());
    if (!panel)
        return QVariant();

    QVariant propertyValue;
    switch (role)
    {
        case PanelObj::PANELOBJ:
            return QVariant::fromValue<PanelObj *>(panel);

        case Qt::DisplayRole:
            propertyIndex += index.column();
            break;

        default:
            propertyIndex += role - Qt::UserRole;
        break;
    }

    if(propertyIndex < panelMetaObject.propertyCount()
            && propertyIndex >= panelMetaObject.propertyOffset()) {
        propertyName = panelMetaObject.property(propertyIndex).name();
        propertyValue = panel->property(propertyName.toLocal8Bit());
    }

    if (!propertyValue.isNull())
        return propertyValue;
    else if (!propertyName.isNull())
        return propertyName;
    else
        return QVariant();

}

void PanelModel::clearPanelList()
{
    this->beginResetModel();
    mPanelList.clear();
    this->endResetModel();
}


bool PanelModel::loadPanels()
{
    clearPanelList();

    QDir dir(PANEL_DESKTOP_PATH);
    if (!dir.exists())
        return false;

    QStringList filters;
    filters << "*.panel";

    foreach (const QString& file, dir.entryList(filters)) {
        PanelObj* aPanel = new PanelObj(dir.absoluteFilePath(file),
                                        mSettings, mConfWatcher, this);
        if (!aPanel->isValid())
            continue;
        mPanelList.append(aPanel);
        connect(aPanel,
                SIGNAL(dataChanged(PanelObj*)),
                this,
                SLOT(onDataChanged(PanelObj*)));
    }

    return true;
}

void PanelModel::onDataChanged(PanelObj* panel)
{
    int i;
    for (i = 0; i < mPanelList.count(); ++i) {
        if (panel->uniqueName() == mPanelList[i]->uniqueName()) {
            QModelIndex qmiTL = this->index(i, PanelObj::DESKTOPFILENAME - Qt::UserRole);
            QModelIndex qmiBR = this->index(i, PanelObj::VISIBLE - Qt::UserRole);
            emit dataChanged(qmiTL, qmiBR);
            break;
        }
    }
}
