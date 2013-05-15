/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

// -*- mode: c++ -*-
#ifndef MUSICINTERFACE_H
#define MUSICINTERFACE_H

//#include "innermusicinterface.h"
#include <QDBusServiceWatcher>
#include <QString>
#include <QStringList>

class ComMeeGoAppMusicInterface;

class MusicInterface : public QObject
{
  Q_OBJECT;
  Q_PROPERTY(QString state READ state NOTIFY stateChanged);
  //Q_PROPERTY(QStringList nowNextTracks READ nowNextTracks NOTIFY nowNextTracksChanged);
  Q_PROPERTY(QString nowTrack READ nowTrack NOTIFY nowTrackChanged);
  Q_PROPERTY(QStringList nextTracks READ nextTracks NOTIFY nextTracksChanged);
  Q_PROPERTY(int nextTrackCount READ nextTrackCount NOTIFY nextTrackCountChanged);

  
public:
  explicit MusicInterface(QObject *parent = NULL);
  ~MusicInterface();

  Q_INVOKABLE void refresh();

  QString state() const;
  //void setState(QString state);
  //QStringList nowNextTracks() const;
  //void setNowNextTracks(QStringList nowNextTracks);
  QString nowTrack() const;
  QStringList nextTracks() const;
  int nextTrackCount() const;

public slots:
  void next();
  void prev();
  void play();
  void pause();

signals:
  void stateChanged();
  void nowTrackChanged();
  void nextTracksChanged();
  void nextTrackCountChanged();
  //void nowNextTracksChanged();

private:
  bool innerIsValid() const;
  ComMeeGoAppMusicInterface *m_innerMI;
  QDBusServiceWatcher *m_serviceWatcher;

private slots:
  void serviceRegistered();
  void serviceUnregistered();
};


#endif
