#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

// QML's read-only view of Logos::ThemeStore. Apps' views import Logos.Theme
// too, so switching and installing go through the host's ThemeManager.
class ThemeRegistry : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QVariantList themes READ themes NOTIFY themesChanged)
    Q_PROPERTY(QStringList paletteTokens READ paletteTokens CONSTANT)
    Q_PROPERTY(QString current READ current NOTIFY currentChanged)
    Q_PROPERTY(QVariantMap palette READ palette NOTIFY paletteChanged)

public:
    explicit ThemeRegistry(QObject* parent = nullptr);

    QVariantList themes() const;
    QStringList paletteTokens() const;
    QString current() const;
    QVariantMap palette() const;
    Q_INVOKABLE QVariantMap paletteOf(const QString& id) const;

signals:
    void themesChanged();
    void currentChanged();
    void paletteChanged();
};
