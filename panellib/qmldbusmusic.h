/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

/*
 * This file was generated by qdbusxml2cpp version 0.7
 * Command line was: qdbusxml2cpp -N -p qmldbusmusic.h:qmldbusmusic.cpp qmldbusmusic.xml
 *
 * qdbusxml2cpp is Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
 *
 * This is an auto-generated file.
 * Do not edit! All changes made to it will be lost.
 */

#ifndef QMLDBUSMUSIC_H_1296716360
#define QMLDBUSMUSIC_H_1296716360

#include <QtCore/QObject>
#include <QtCore/QByteArray>
#include <QtCore/QList>
#include <QtCore/QMap>
#include <QtCore/QString>
#include <QtCore/QStringList>
#include <QtCore/QVariant>
#include <QtDBus/QtDBus>

/*
 * Proxy class for interface com.meego.app.music
 */
class ComMeeGoAppMusicInterface: public QDBusAbstractInterface
{
    Q_OBJECT
public:
    static inline const char *staticInterfaceName()
    { return "com.meego.app.music"; }

public:
    ComMeeGoAppMusicInterface(const QString &service, const QString &path, const QDBusConnection &connection, QObject *parent = 0);

    ~ComMeeGoAppMusicInterface();

    Q_PROPERTY(QStringList nowNextTracks READ nowNextTracks)
    inline QStringList nowNextTracks() const
    { return qvariant_cast< QStringList >(property("nowNextTracks")); }

    Q_PROPERTY(QString state READ state)
    inline QString state() const
    { return qvariant_cast< QString >(property("state")); }

public Q_SLOTS: // METHODS
    inline QDBusPendingReply<> next()
    {
        QList<QVariant> argumentList;
        return asyncCallWithArgumentList(QLatin1String("next"), argumentList);
    }

    inline QDBusPendingReply<> pause()
    {
        QList<QVariant> argumentList;
        return asyncCallWithArgumentList(QLatin1String("pause"), argumentList);
    }

    inline QDBusPendingReply<> play()
    {
        QList<QVariant> argumentList;
        return asyncCallWithArgumentList(QLatin1String("play"), argumentList);
    }

    inline QDBusPendingReply<> prev()
    {
        QList<QVariant> argumentList;
        return asyncCallWithArgumentList(QLatin1String("prev"), argumentList);
    }

Q_SIGNALS: // SIGNALS
    void nowNextTracksChanged();
    void stateChanged();
};

#endif
