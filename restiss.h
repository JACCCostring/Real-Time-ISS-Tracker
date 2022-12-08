#ifndef RESTISS_H
#define RESTISS_H

#include <QObject>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QTimer>

class RestISS : public QObject
{
    Q_OBJECT
    Q_PROPERTY(double latitude READ latitude WRITE setLatitude NOTIFY latitudeChanged)
    Q_PROPERTY(double longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged)
    Q_PROPERTY(double velocity READ velocity WRITE setVelocity NOTIFY velocityChanged)
    Q_PROPERTY(double altitude READ altitude WRITE setAltitude NOTIFY altitudeChanged)

public:
    //constructor
    explicit RestISS(QObject *parent = nullptr);
    //destructor
    ~RestISS();
    //Q_INVOKABLE method
    Q_INVOKABLE void startTimer();
    Q_INVOKABLE void stopTimer();
    Q_INVOKABLE void setIntervals(int);
    //normal method
    void startTracking();
    //latitude getters and setters
    double latitude() const;
    void setLatitude(double newLatitude);
    //longitude getters and setters
    double longitude() const;
    void setLongitude(double newLongitude);
    //velocity getters and setters
    double velocity() const;
    void setVelocity(double newVelocity);
    //altitude getters and setters
    double altitude() const;
    void setAltitude(double newAltitude);

private slots:
        void requestDone(QNetworkReply *);

signals:
        void latitudeChanged();
        void longitudeChanged();
        void velocityChanged();
        void altitudeChanged();

private:
    QNetworkAccessManager *RESTManager = nullptr;
    QTimer *timer;
    double m_latitude;
    double m_longitude;
    double m_velocity;
    double m_altitude;
    int m_intervals;
};

#endif // RESTISS_H
