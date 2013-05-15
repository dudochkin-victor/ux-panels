/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "musicinterface.h"

#include "qmldbusmusic.h"

#define SERVICE "com.meego.app.music"

#include <QDBusReply>
#include <QDBusConnectionInterface>

MusicInterface::MusicInterface(QObject *parent) : QObject(parent) , m_innerMI(0)
{
  m_serviceWatcher = new QDBusServiceWatcher(SERVICE,
					     QDBusConnection::sessionBus(), 
					     QDBusServiceWatcher::WatchForRegistration |
					     QDBusServiceWatcher::WatchForUnregistration,
					     this);
  connect(m_serviceWatcher, SIGNAL(serviceRegistered(const QString &)),
	  this, SLOT(serviceRegistered()));
  connect(m_serviceWatcher, SIGNAL(serviceUnregistered(const QString &)),
	  this, SLOT(serviceUnregistered()));

  QDBusReply<bool> registered= QDBusConnection::sessionBus().interface()->isServiceRegistered(SERVICE);
  if (registered.isValid()) {
    if (registered.value()) {
      serviceRegistered();
    };
  }
}

MusicInterface::~MusicInterface()
{
}

void MusicInterface::refresh()
 {
    state();
    nowTrack();
    emit stateChanged();
    emit nowTrackChanged();
    emit nextTracksChanged();
    emit nextTrackCountChanged();
}

QString MusicInterface::state() const
{
  if (innerIsValid()) {
    return m_innerMI->state();
  } else {
    return "stopped";
  }
}

QString MusicInterface::nowTrack() const
{
    if (innerIsValid()) {
        QStringList nnT = m_innerMI->nowNextTracks();
        if (nnT.count() > 0)
            return nnT[0];
    }
    return QString();
}

QStringList MusicInterface::nextTracks() const
{
    QStringList retVal;
    if (innerIsValid()) {
        QStringList nnT = m_innerMI->nowNextTracks();
        int i;
        for (i = 1; i < nnT.count(); ++i)
            if (nnT[i] != "")
                retVal << nnT[i];
    }
    return retVal;
}

int MusicInterface::nextTrackCount() const
{
    if (innerIsValid())
        return this->nextTracks().count();
    else
        return 0;
}

//void MusicInterface::setState(QString state)
//{
//  if (innerIsValid()) {
//    m_innerMI->setProperty("state", state);
//  }
//}

//QStringList MusicInterface::nowNextTracks() const
//{
//  if (innerIsValid()) {
//    return m_innerMI->property("nowNextTracks").toStringList();
//  } else {
//    return QStringList() << "" << "";
//  }
//}

//void MusicInterface::setNowNextTracks(QStringList nowNextTracks)
//{
//  if (innerIsValid()) {
//    m_innerMI->setProperty("nowNextTracks", nowNextTracks);
//  }
//}

void MusicInterface::next()
{
  if (innerIsValid()) {
    m_innerMI->next();
  } 
}

void MusicInterface::prev()
{
  if (innerIsValid()) {
    m_innerMI->prev();
  }
}

void MusicInterface::play()
{
  if (innerIsValid()) {
    m_innerMI->play();
  }
}

void MusicInterface::pause()
{
  if (innerIsValid()) {
    m_innerMI->pause();
  }
}

bool MusicInterface::innerIsValid() const
{
  if (m_innerMI) {
    if (m_innerMI->isValid()) {
      return true;
    } 
  }
  return false;
}

void MusicInterface::serviceRegistered()
{
  m_innerMI = new ComMeeGoAppMusicInterface(SERVICE, "/com/meego/app/music",
                                               QDBusConnection::sessionBus(), this);
  if (!m_innerMI->isValid()) {
      QDBusError err = m_innerMI->lastError();
      qDebug() << QString("Error instantiating the music intf: %1 - %2!").arg(err.name(), err.message());
      serviceUnregistered();
  } else {
      connect(m_innerMI, SIGNAL(stateChanged()), this, SIGNAL(stateChanged()));
      connect(m_innerMI, SIGNAL(nowNextTracksChanged()), this, SIGNAL(nowTrackChanged()));
      connect(m_innerMI, SIGNAL(nowNextTracksChanged()), this, SIGNAL(nextTracksChanged()));
      connect(m_innerMI, SIGNAL(nowNextTracksChanged()), this, SIGNAL(nextTrackCountChanged()));
      emit stateChanged();
      emit nowTrackChanged();
      emit nextTracksChanged();
      emit nextTrackCountChanged();
  }
}

void MusicInterface::serviceUnregistered()
{
  if (m_innerMI) {
    m_innerMI->deleteLater();
  }
  m_innerMI = NULL;
  emit stateChanged();
}
