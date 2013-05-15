/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#include "panelproxymodel.h"
#include "panelmodel.h"

#include <QMetaObject>
#include <QMetaProperty>
#include <QDebug>


PanelProxyModel::PanelProxyModel(QObject *parent) :
    QSortFilterProxyModel(parent),
    mSortType(SortTypeIndex),
    mFilterType(FilterTypeNone)
{
    PanelModel *aPanelModel = new PanelModel(this);
    setSourceModel(aPanelModel);

    setDynamicSortFilter(true);
    sort(PanelObj::INDEX - Qt::UserRole);
    //Easy way to make sure all panels have a valid index - i.e. not -1
    if (rowCount() > 0)
        move(0, 0);
}

PanelProxyModel::~PanelProxyModel()
{
    if (rowCount() > 0)
        move(0, 0);
}

void PanelProxyModel::setSortType(PanelProxyModel::SortType sortType)
{
    mSortType = sortType;
    if (sortType == PanelProxyModel::SortTypeIndex)
        sort(PanelObj::INDEX - Qt::UserRole);
    else if (sortType == PanelProxyModel::SortTypeDefaultIndex)
        sort(PanelObj::DEFAULTINDEX - Qt::UserRole);
    emit sortTypeChanged();
}

void PanelProxyModel::setFilterType(PanelProxyModel::FilterType filterType)
{
    mFilterType = filterType;
    emit filterTypeChanged();
    this->invalidateFilter();
}

bool PanelProxyModel::filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const
{
    QModelIndex index0 = sourceModel()->index(sourceRow, 0, sourceParent);
    if (mFilterType == PanelProxyModel::FilterTypeHidden)
        return sourceModel()->data(index0, PanelObj::VISIBLE).toBool();
    else
        return true;
}

bool PanelProxyModel::lessThan (const QModelIndex & left, const QModelIndex & right) const
{
    int lIdx, rIdx;
    if (mSortType == PanelProxyModel::SortTypeIndex) {
        lIdx = left.data(PanelObj::INDEX).toInt();
        rIdx = right.data(PanelObj::INDEX).toInt();
    } else if (mSortType == PanelProxyModel::SortTypeDefaultIndex) {
        lIdx = left.data(PanelObj::DEFAULTINDEX).toInt();
        rIdx = right.data(PanelObj::DEFAULTINDEX).toInt();
    } else {
        lIdx = -1;
        rIdx = -1;
    }

    //Handle the un-indexed panels...
    if (lIdx == -1) {
        return false;
    }
    if (rIdx == -1) return true;

    return lIdx < rIdx;
}

void PanelProxyModel::move (int oldPos, int newPos)
{
    //Not sure if there's a better way to do this, but it seemed
    //the most simple to me
    int i;
    QList<PanelObj *> panelList;
    for (i = 0; i < this->rowCount(); ++i) {
        PanelObj *pnl = data(index(i, 0), PanelObj::PANELOBJ).value<PanelObj *>();
        if (pnl) {
            panelList.append(pnl);
        }
    }

    if (oldPos >= panelList.count())
        return;

    if (newPos >= panelList.count())
        newPos = panelList.count() - 1;

    panelList.move(oldPos, newPos);
    if (oldPos != newPos)
        emit this->layoutAboutToBeChanged();
    for (i = 0; i < panelList.count(); ++i) {

        qDebug() << "Name: " << panelList[i]->uniqueName() << " OldIndex/NewIndex: " << panelList[i]->index() << "/" << i;
        panelList[i]->setIndex(i);
    }
    if (oldPos != newPos)
        emit this->layoutChanged();
}

