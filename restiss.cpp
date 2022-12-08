#include "restiss.h"

RestISS::RestISS(QObject *parent) :
    QObject(parent)
{
    //initializing timer
    timer = new QTimer(this);
    //connecting timer
    connect(timer, &QTimer::timeout, this, &RestISS::startTracking);
}

RestISS::~RestISS()
{   //deleting QNAM to avoid dangling ptr if it's initialized
    if(RESTManager != nullptr)
    RESTManager->deleteLater();
}

void RestISS::startTimer()
{
    //starting timer
    timer->start();
}

void RestISS::stopTimer()
{
    //stopping timer
    timer->stop();
}

void RestISS::setIntervals(int newIntervals)
{
    if(m_intervals == newIntervals)
        return;
    //setting timer intervals
    timer->setInterval(newIntervals * 1000);
}

void RestISS::startTracking()
{
    //end point for REST request
    QString endPoint = "https://api.wheretheiss.at/v1/satellites/25544";
    //init.. QNAM
    RESTManager = new QNetworkAccessManager(this);
    //making REST request
    RESTManager->get(QNetworkRequest(QUrl(endPoint)));
    //connecting obj
    connect(RESTManager, &QNetworkAccessManager::finished, this, &RestISS::requestDone);
}

void RestISS::requestDone(QNetworkReply *replay)
{
    //getting raw json data
    QByteArray rawJson = replay->readAll();
    //converting from formatted json to QJsonDocument format
    QJsonDocument jsonDocument = QJsonDocument::fromJson(rawJson);
    //getting json objs
    QJsonObject mainJsonObj = jsonDocument.object();
    //getting specific data from json Object
    double latitude = mainJsonObj["latitude"].toDouble();
    double longitude = mainJsonObj["longitude"].toDouble();
    double velocity = mainJsonObj["velocity"].toDouble();
    double _altitude = mainJsonObj["altitude"].toDouble();
    //setting latitude and longitude coords
    setLatitude(latitude);
    setLongitude(longitude);
    setVelocity(velocity);
    //explicit cast to double to avoid crashed
    setAltitude((double)_altitude);
    //cleaning on each time a get request is made
    //to avoid thread limit call connections in the QNetworkAccessManage
    RESTManager->clearConnectionCache();
    //deleting QNetworkReply * after used
    //replay->deleteLater();
}

double RestISS::longitude() const
{
    return m_longitude;
}

void RestISS::setLongitude(double newLongitude)
{
    if (qFuzzyCompare(m_longitude, newLongitude))
        return;

    m_longitude = newLongitude;
    emit longitudeChanged();
}

double RestISS::latitude() const
{
    return m_latitude;
}

void RestISS::setLatitude(double newLatitude)
{
    if (qFuzzyCompare(m_latitude, newLatitude))
        return;

    m_latitude = newLatitude;
    emit latitudeChanged();
}

double RestISS::velocity() const
{
    return m_velocity;
}

void RestISS::setVelocity(double newVelocity)
{
    if (qFuzzyCompare(m_velocity, newVelocity))
        return;

    m_velocity = newVelocity;
    emit velocityChanged();
}

double RestISS::altitude() const
{
    return m_altitude;
}

void RestISS::setAltitude(double newAltitude)
{
    if (newAltitude == m_altitude)
        return;
        //parameter received need an explicit type cast before passed to the method
    m_altitude = newAltitude;
    emit altitudeChanged();
}
