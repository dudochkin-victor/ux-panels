/*
 * Copyright 2011 Intel Corporation.
 *
 * This program is licensed under the terms and conditions of the
 * Apache License, version 2.0.  The full text of the Apache License is at 	
 * http://www.apache.org/licenses/LICENSE-2.0
 */

#ifndef PANELPROXYMODEL_H
#define PANELPROXYMODEL_H

#include <QObject>
#include <QSortFilterProxyModel>

class PanelProxyModel : public QSortFilterProxyModel
{
    Q_OBJECT

    Q_PROPERTY(SortType sortType READ sortType WRITE setSortType NOTIFY sortTypeChanged)
    Q_PROPERTY(FilterType filterType READ filterType WRITE setFilterType NOTIFY filterTypeChanged)


public:
    explicit PanelProxyModel(QObject *parent = 0);
    ~PanelProxyModel();

    enum SortType {
        SortTypeIndex,
        SortTypeDefaultIndex
    };

    enum FilterType {
        FilterTypeNone,
        FilterTypeHidden
    };

    Q_ENUMS(SortType)
    Q_ENUMS(FilterType)

    Q_INVOKABLE SortType sortType() const { return mSortType; }
    Q_INVOKABLE void setSortType(PanelProxyModel::SortType sortType);
    Q_INVOKABLE FilterType filterType() const { return mFilterType; }
    Q_INVOKABLE void setFilterType(PanelProxyModel::FilterType filterType);

signals:
    void sortTypeChanged();
    void filterTypeChanged();

public slots:
    void move(int oldPosition, int newPosition);
    bool filterAcceptsRow(int sourceRow,
                          const QModelIndex &sourceParent) const;

protected:
    bool lessThan (const QModelIndex &left, const QModelIndex &right) const;

private:
    SortType mSortType;
    FilterType mFilterType;

};

#endif // PANELPROXYMODEL_H
