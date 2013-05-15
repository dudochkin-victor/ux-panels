/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "panelobj.h"

#include <QSettings>
#include <QFileInfo>
#include <QFileSystemWatcher>
#include <QDateTime>
#include <QTimer>
#include <QLocale>
//#include <QDebug>


const QString PanelObj::m_DisplayNameKey("DisplayName");

PanelObj::PanelObj(const QString &name, QSettings *settings,
                   QFileSystemWatcher *confWatcher, QObject *parent) :
    QObject(parent),
    mSettings(0),
    mConfWatcher(0),
    mHiddenItemsTimer(0),
    mValid(false),
    mDesktopFileName(name),
    mVisible(true)
{
    //If we can't read the panel file specified, then we return, leaving
    //mValid as false. If this happens, the creating code should discard
    //the created PanelObj

    QFileInfo fi(mDesktopFileName);
    if (!fi.exists() || !fi.isReadable())
        return;

    if (!mSettings)
        mSettings = new QSettings(SETTINGS_ORG, SETTINGS_APP, this);

    //Watch our conf file, so we can see if anyone changes our settings...
    if (!mConfWatcher)
        mConfWatcher = new QFileSystemWatcher(QStringList() << mSettings->fileName());

    connect(mConfWatcher,
            SIGNAL(fileChanged(QString)),
            this,
            SLOT(readConfFile()));

    //In case it's not set in the .panel file, default to the basename
    //of the .panel file - i.e. "/blah/friends.panel" would end up
    //as "friends"
    mUniqueName = fi.baseName();

    if (!readDesktopFile())
        return;

    mIndex = mDefaultIndex;
    readConfFile();

    loadHiddenItems();
    filterHiddenItems();

    mValid = true;
}

PanelObj::~PanelObj()
{
    saveHiddenItems();
}

void PanelObj::setIndex(int index)
{
    if (index != mIndex) {
        mIndex = index;
        saveSettings();
        emit indexChanged(this);
    }
}

void PanelObj::setVisible(bool isVisible)
{
    if (!mAllowHide)
        isVisible = true;
    if (isVisible != mVisible) {
        mVisible = isVisible;
        saveSettings();
        emit visibleChanged(this);
    }
}

QVariant PanelObj::getCustomProp(const QString &propName)
{
    return mCustomProps.value(propName, QVariant());
}

QVariant PanelObj::getCustomProp(const QString &propName, const QVariant &defaultValue)
{
    if (!mCustomProps.contains(propName)) {
        setCustomProp(propName, defaultValue);
    }
    //qDebug() << "About to return " << mCustomProps.value(propName) << " for propName " << propName;
    return mCustomProps.value(propName);
}

void PanelObj::setCustomProp(const QString &propName, const QVariant &customProp)
{
    if (!mSettings)
        mSettings = new QSettings(SETTINGS_ORG, SETTINGS_APP, this);

    mCustomProps.insert(propName, customProp);
    if (!mCustomProps.isEmpty()) {
        mSettings->beginGroup(mCustomSectionName);
        foreach (const QString &key, mCustomProps.keys()) {
            mSettings->setValue(key, mCustomProps.value(key));
        }
        mSettings->endGroup();
    }
    delete mSettings;
    mSettings = 0;

}

void PanelObj::addHiddenItem(const QString &itemID)
{
    mHiddenItems.insert(itemID, QVariant::fromValue(QDateTime::currentDateTime()));
    emit hiddenItemsChanged(this);
    if (!mHiddenItemsTimer) {
        mHiddenItemsTimer = new QTimer(this);
        mHiddenItemsTimer->setInterval(30 * 60 * 1000); //Check every 30 minutes...
        connect(mHiddenItemsTimer,
                SIGNAL(timeout()),
                this,
                SLOT(hiddenItemsTimeout()));
        mHiddenItemsTimer->start();
    }
    saveHiddenItems();
}

//Private slots:

void PanelObj::readConfFile()
{
    //mSettings->sync();
    if (!mSettings)
        mSettings = new QSettings(SETTINGS_ORG, SETTINGS_APP, this);

    //Only bother processing if we have a section for this panel...
    if (!mSettings->childGroups().contains(mUniqueName)
            && !mSettings->childGroups().contains(mCustomSectionName))
        return;

    mSettings->beginGroup(mUniqueName);
    //Fall back to Default Index
    mIndex = mSettings->value("Index", mDefaultIndex).toInt();
    if (mAllowHide)
        mVisible = mSettings->value("Visible", true).toBool();
    else
        mVisible = true;
    mSettings->endGroup();

    if (mSettings->childGroups().contains(mCustomSectionName)) {
        mSettings->beginGroup(mCustomSectionName);
        foreach (const QString &key, mSettings->childKeys()) {
            mCustomProps.insert(key, mSettings->value(key));
        }
        mSettings->endGroup();
    }
    emit dataChanged(this);
    //Unfortunately need to do this - if we just ::sync at the beginning
    //of readConfFile, the ::sync method touches the QSettings file, which triggers
    //another readConfFile, ad infinitum - whole system starts breaking.
    //So we go through the thrash of closing and reopening the QSettings file
    //whenever it changes, or we save settings...
    delete mSettings;
    mSettings = 0;
}

void PanelObj::hiddenItemsTimeout()
{
    filterHiddenItems();
}

//Private functions:

bool PanelObj::readDesktopFile()
{
    QSettings dt(mDesktopFileName, QSettings::IniFormat);

    dt.beginGroup("Panel");

    //If we don't have a path to the .qml file, then
    //we can't run the panel!
    if (!dt.contains("Path"))
        return false;

    mPath = dt.value("Path").toString();

    //First we try to grab it by lang_COUNTRY, then by lang, then fallback to non-translated
    QString locale = QLocale::system().name();
    QString lang = locale.split("_").at(0);

    QString LocalizedDisplayNameKey = m_DisplayNameKey + QString("[%1]").arg(locale);
    mDisplayName = dt.value(LocalizedDisplayNameKey).toString();
    if (mDisplayName.isEmpty()) {
        LocalizedDisplayNameKey = m_DisplayNameKey + QString("[%1]").arg(lang);
        mDisplayName = dt.value(LocalizedDisplayNameKey).toString();
    }
    if (mDisplayName.isEmpty())
        mDisplayName = dt.value(m_DisplayNameKey, mUniqueName).toString();

    mUniqueName = dt.value("UniqueName", mUniqueName).toString();
    mSettingsIcon = dt.value("SettingsIcon").toString();
    mColor = dt.value("Color").toString();
    mAllowHide = dt.value("AllowHide", true).toBool();
    //In PanelModel, if we see the DefaultIndex and Index are both -1,
    //we just assign the next available index
    mDefaultIndex = dt.value("DefaultIndex", -1).toInt();

    mCustomSectionName = QString("%1_%2").arg(mUniqueName, "CustomProps");

    dt.endGroup();

    if (dt.childGroups().contains("CustomProps")) {
        dt.beginGroup("CustomProps");
        foreach (const QString &key, dt.childKeys()) {
            mCustomProps.insert(key, dt.value(key));
        }
        dt.endGroup();
    }

    emit dataChanged(this);

    return true;
}

void PanelObj::saveSettings()
{
    if (!mSettings)
        mSettings = new QSettings(SETTINGS_ORG, SETTINGS_APP, this);

    mSettings->beginGroup(mUniqueName);
    mSettings->setValue("Index", mIndex);
    mSettings->setValue("Visible", mVisible);
    mSettings->endGroup();

    if (!mCustomProps.isEmpty()) {
        mSettings->beginGroup(mCustomSectionName);
        foreach (const QString &key, mCustomProps.keys()) {
            mSettings->setValue(key, mCustomProps.value(key));
        }
        mSettings->endGroup();
    }
    mSettings->sync();
    delete mSettings;
    mSettings = 0;
}

void PanelObj::loadHiddenItems()
{
    QSettings *hSettings = new QSettings(SETTINGS_ORG, QString("%1-%2-hidden-items").arg(SETTINGS_APP, mUniqueName));
    mHiddenItems = hSettings->value("HiddenItems").toHash();
    if (mHiddenItems.count() && !mHiddenItemsTimer) {
        mHiddenItemsTimer = new QTimer(this);
        mHiddenItemsTimer->setInterval(30 * 60 * 1000); //Check every 30 minutes...
        connect(mHiddenItemsTimer,
                SIGNAL(timeout()),
                this,
                SLOT(hiddenItemsTimeout()));
        mHiddenItemsTimer->start();
    }
    emit hiddenItemsChanged(this);
}

void PanelObj::saveHiddenItems()
{
    QSettings *hSettings = new QSettings(SETTINGS_ORG, QString("%1-%2-hidden-items").arg(SETTINGS_APP, mUniqueName));
    hSettings->setValue("HiddenItems", mHiddenItems);
}

void PanelObj::filterHiddenItems()
{
    //Currently, expire hidden items after 30 days - this should probably become a user setting
    QDateTime expBefore = QDateTime::currentDateTime().addDays(-30);
    QStringList removeItems;
    bool modified = false;

    QHash<QString, QVariant>::const_iterator i;
    for (i = mHiddenItems.constBegin(); i != mHiddenItems.constEnd(); ++i) {
        if (i.value().toDateTime() <= expBefore) {
            removeItems.append(i.key());
            modified = true;
        }
    }
    if (modified) {
        foreach (const QString &key, removeItems)
            mHiddenItems.remove(key);

        saveHiddenItems();
        emit hiddenItemsChanged(this);
        if (!mHiddenItems.count() && mHiddenItemsTimer)
            mHiddenItemsTimer->stop();
    }

}
