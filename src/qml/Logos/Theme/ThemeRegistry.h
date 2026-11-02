#pragma once

#include <QObject>
#include <QStringList>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>

// QML's view of Logos::ThemeStore: read the themes, switch between them.
// Apps' views import Logos.Theme too, so it offers nothing else.
class ThemeRegistry : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QVariantList themes READ themes NOTIFY themesChanged)
    Q_PROPERTY(QStringList paletteTokens READ paletteTokens CONSTANT)
    Q_PROPERTY(QString current READ current WRITE setCurrent NOTIFY currentChanged)

public:
    explicit ThemeRegistry(QObject* parent = nullptr);

    QVariantList themes() const;
    QStringList paletteTokens() const;
    QString current() const;
    void setCurrent(const QString& id);

signals:
    void themesChanged();
    void currentChanged();
};
