/***************************************************************************
    qgsspinbox.cpp
     --------------------------------------
    Date                 : 09.2014
    Copyright            : (C) 2014 Denis Rouzaud
    Email                : denis.rouzaud@gmail.com
 ***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/

#include <QLineEdit>
#include <QMouseEvent>
#include <QSettings>
#include <QStyle>
#include <QToolButton>

#include "qgsspinbox.h"
#include "qgsexpression.h"
#include "qgsapplication.h"
#include "qgslogger.h"

QgsSpinBox::QgsSpinBox( QWidget *parent )
    : QSpinBox( parent )
    , mShowClearButton( true )
    , mClearValueMode( MinimumValue )
    , mCustomClearValue( 0 )
    , mExpressionsEnabled( true )
{
  mClearButton = new QToolButton( this );
  mClearButton->setIcon( QgsApplication::getThemeIcon( "/mIconClear.svg" ) );
  mClearButton->setCursor( Qt::ArrowCursor );
  mClearButton->setStyleSheet( "position: absolute; border: none; padding: 0px;" );
  connect( mClearButton, SIGNAL( clicked() ), this, SLOT( clear() ) );

  setStyleSheet( QString( "padding-right: %1px;" ).arg( mClearButton->sizeHint().width() + 18 + frameWidth() + 1 ) );

  QSize msz = minimumSizeHint();
  setMinimumSize( qMax( msz.width(), mClearButton->sizeHint().height() + frameWidth() * 2 + 2 ),
                  qMax( msz.height(), mClearButton->sizeHint().height() + frameWidth() * 2 + 2 ) );

  connect( this, SIGNAL( valueChanged( int ) ), this, SLOT( changed( int ) ) );
}

void QgsSpinBox::setShowClearButton( const bool showClearButton )
{
  mShowClearButton = showClearButton;
  mClearButton->setVisible( shouldShowClearForValue( value() ) );
}

void QgsSpinBox::setExpressionsEnabled( const bool enabled )
{
  mExpressionsEnabled = enabled;
}

void QgsSpinBox::changeEvent( QEvent *event )
{
  QSpinBox::changeEvent( event );
  mClearButton->setVisible( shouldShowClearForValue( value() ) );
}

void QgsSpinBox::paintEvent( QPaintEvent *event )
{
  mClearButton->setVisible( shouldShowClearForValue( value() ) );
  QSpinBox::paintEvent( event );
}

void QgsSpinBox::changed( const int& value )
{
  mClearButton->setVisible( shouldShowClearForValue( value ) );
}

void QgsSpinBox::clear()
{
  setValue( clearValue() );
}

void QgsSpinBox::setClearValue( int customValue, const QString& specialValueText )
{
  mClearValueMode = CustomValue;
  mCustomClearValue = customValue;

  if ( !specialValueText.isEmpty() )
  {
    int v = value();
    clear();
    setSpecialValueText( specialValueText );
    setValue( v );
  }
}

void QgsSpinBox::setClearValueMode( QgsSpinBox::ClearValueMode mode, const QString& specialValueText )
{
  mClearValueMode = mode;
  mCustomClearValue = 0;

  if ( !specialValueText.isEmpty() )
  {
    int v = value();
    clear();
    setSpecialValueText( specialValueText );
    setValue( v );
  }
}

int QgsSpinBox::clearValue() const
{
  if ( mClearValueMode == MinimumValue )
    return minimum() ;
  else if ( mClearValueMode == MaximumValue )
    return maximum();
  else
    return mCustomClearValue;
}

int QgsSpinBox::valueFromText( const QString &text ) const
{
  if ( !mExpressionsEnabled )
  {
    return QSpinBox::valueFromText( text );
  }

  QString trimmedText = stripped( text );
  if ( trimmedText.isEmpty() )
  {
    return mShowClearButton ? clearValue() : value();
  }

  return qRound( QgsExpression::evaluateToDouble( trimmedText, value() ) );
}

QValidator::State QgsSpinBox::validate( QString &input, int &pos ) const
{
  if ( !mExpressionsEnabled )
  {
    QValidator::State r = QSpinBox::validate( input, pos );
    return r;
  }

  return QValidator::Acceptable;
}

int QgsSpinBox::frameWidth() const
{
  return style()->pixelMetric( QStyle::PM_DefaultFrameWidth );
}

bool QgsSpinBox::shouldShowClearForValue( const int value ) const
{
  if ( !mShowClearButton || !isEnabled() )
  {
    return false;
  }
  return value != clearValue();
}

QString QgsSpinBox::stripped( const QString &originalText ) const
{
  //adapted from QAbstractSpinBoxPrivate::stripped
  //trims whitespace, prefix and suffix from spin box text
  QString text = originalText;
  if ( specialValueText().isEmpty() || text != specialValueText() )
  {
    int from = 0;
    int size = text.size();
    bool changed = false;
    if ( !prefix().isEmpty() && text.startsWith( prefix() ) )
    {
      from += prefix().size();
      size -= from;
      changed = true;
    }
    if ( !suffix().isEmpty() && text.endsWith( suffix() ) )
    {
      size -= suffix().size();
      changed = true;
    }
    if ( changed )
      text = text.mid( from, size );
  }

  text = text.trimmed();

  return text;
}

void QgsSpinBox::resizeEvent( QResizeEvent * event )
{
  QSpinBox::resizeEvent( event );

  QSize sz = mClearButton->sizeHint();

  mClearButton->move( rect().right() - frameWidth() - 18 - sz.width(),
                      ( rect().bottom() + 1 - sz.height() ) / 2 );

}
