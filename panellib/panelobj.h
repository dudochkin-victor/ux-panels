/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef PANELOBJ_H
#define PANELOBJ_H

#include <QObject>
#include <QVariant>
#include <QString>
#include <QHash>
#include <QStringList>

class QSettings;
class QFileSystemWatcher;
class QTimer;

class PanelObj : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString DesktopFileName READ desktopFileName)
    Q_PROPERTY(QString DisplayName READ displayName)
    Q_PROPERTY(QString UniqueName READ uniqueName)
    Q_PROPERTY(QString SettingsIcon READ settingsIcon)
    Q_PROPERTY(QString Path READ path)
    Q_PROPERTY(QString Color READ getColor NOTIFY colorChanged)
    Q_PROPERTY(QStringList HiddenItems READ getHiddenItems NOTIFY hiddenItemsChanged)
    Q_PROPERTY(bool AllowHide READ allowHide)
    Q_PROPERTY(int DefaultIndex READ defaultIndex)
    Q_PROPERTY(int Index READ index WRITE setIndex NOTIFY indexChanged)
    Q_PROPERTY(bool IsVisible READ isVisible WRITE setVisible NOTIFY visibleChanged)
    Q_PROPERTY(bool IsValid READ isValid)

    //In the same order as the properties are declared
    enum Role {
        DESKTOPFILENAME   = Qt::UserRole,
        DISPLAYNAME       = Qt::UserRole + 1,
        UNIQUENAME        = Qt::UserRole + 2,
        SETTINGSICON      = Qt::UserRole + 3,
        PATH              = Qt::UserRole + 4,
        COLOR             = Qt::UserRole + 5,
        HIDDENITEMS       = Qt::UserRole + 6,
        ALLOWHIDE         = Qt::UserRole + 7,
        DEFAULTINDEX      = Qt::UserRole + 8,
        INDEX             = Qt::UserRole + 9,
        VISIBLE           = Qt::UserRole + 10,
        PANELOBJ          = Qt::UserRole + 11,
    };

    friend class PanelModel;
    friend class PanelProxyModel;

public:

    explicit PanelObj(const QString &name = QString(), QSettings *settings = 0,
                      QFileSystemWatcher *confWatcher = 0, QObject *parent = 0);
    virtual ~PanelObj();

    QString displayName() { return mDisplayName; }
    QString desktopFileName() { return mDesktopFileName; }
    QString uniqueName() { return mUniqueName; }
    QString settingsIcon () { return mSettingsIcon; }
    QString path() { return mPath; }
    QString getColor() { return mColor; }
    QStringList getHiddenItems() { return mHiddenItems.keys(); }
    bool allowHide() { return mAllowHide; }
    int defaultIndex() { return mDefaultIndex; }

    int index() { return mIndex; }
    void setIndex(int index);

    bool isVisible() { return mVisible; }
    void setVisible(bool isVisible);

    bool isValid() { return mValid; }

    Q_INVOKABLE QVariant getCustomProp(const QString &propName);
    Q_INVOKABLE QVariant getCustomProp(const QString &propName, const QVariant &defaultValue);

    Q_INVOKABLE void setCustomProp(const QString &propName, const QVariant &customProp);

    Q_INVOKABLE void addHiddenItem(const QString &itemID);

signals:
    void indexChanged(PanelObj *panel);
    void visibleChanged(PanelObj *panel);
    void dataChanged(PanelObj *panel);
    void colorChanged(PanelObj *panel);
    void hiddenItemsChanged(PanelObj *panel);

private slots:
    void readConfFile();
    void hiddenItemsTimeout();

private:
    bool readDesktopFile();
    void saveSettings();

    void loadHiddenItems();
    void saveHiddenItems();
    void filterHiddenItems();

    QSettings *mSettings;
    QFileSystemWatcher *mConfWatcher;
    QTimer *mHiddenItemsTimer;
    QString mCustomSectionName;
    bool mValid;

    //Panel Properties:
    //Read-only
    QString mDisplayName;
    QString mDesktopFileName;
    QString mUniqueName;
    QString mSettingsIcon;
    QString mPath;
    QString mColor;
    //Have to use a QVariant for the QDateTime so QSettings knows how
    //to save the QHash to disk...
    QHash<QString, QVariant> mHiddenItems;
    bool mAllowHide;
    int mDefaultIndex;

    //Writable
    int mIndex;
    bool mVisible;

    //For custom property support...
    QHash<QString, QVariant> mCustomProps;

    //Desktop file key names
    static const QString m_DisplayNameKey;
};

Q_DECLARE_METATYPE(PanelObj *);

#endif // PANELOBJ_H
