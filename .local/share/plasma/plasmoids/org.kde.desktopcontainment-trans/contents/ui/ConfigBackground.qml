/***************************************************************************
 *   Copyright (C) 2014 by Eike Hein <hein@kde.org>                        *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.5
import QtQuick.Controls 2.5
import QtQuick.Controls 1.0 
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore

import org.kde.private.desktopcontainment.folder 0.1 as Folder

Kirigami.FormLayout {
    id: configBack
    anchors.left: parent.left
//     spacing: units.smallSpacing
    
    property alias cfg_userdefinedback: userdefinedback.checked
    property alias cfg_usethemebackcolor: usethemebackcolor.checked
    property alias cfg_usercolor: usercolor.text
    property alias cfg_opacityslider: opacityslider.value
    

       ColorDialog {
        id: colorDialog
        title: "Please choose a color"
        //En el orden de los cuatros botones
        property int boton
        onAccepted: {
            usercolor.text = colorDialog.color
    //         console.log("You chose: " + colorDialog.color)
    //         switch(boton){
    //             case 0:
    //                 _min1.text = colorDialog.color
    //                 break
    //             case 1:
    //                 _min2.text = colorDialog.color
    //                 break
    //             case 2:
    //                 _hora1.text = colorDialog.color
    //                 break
    //             case 3:
    //                 _hora2.text = colorDialog.color
    //                 break
    //             case 4:
    //                 _seconds1.text = colorDialog.color
    //                 break
    //             case 5:
    //                 _seconds2.text = colorDialog.color
    //                 break
    //             case 6:
    //                 _text1.text = colorDialog.color
    //                 break
    //             case 7:
    //                 _text2.text = colorDialog.color
    //                 break
    //             }
    //         Qt.quit()
        }
        onRejected: {
    //         console.log("Canceled")
    //         Qt.quit()
        }
    //     Component.onCompleted: visible = true
    }
    
    CheckBox {
		        id: userdefinedback
		        text: i18n('Use an user defined background')
		    }
		    
    GroupBox {
        Layout.fillWidth: true
        title: i18n("Background color")
        flat: true
        visible: userdefinedback.checked
        
        ColumnLayout {
            
                CheckBox {
                        id: usethemebackcolor
                        text: i18n('Use the default background color of the teme.')
                    }
                
                RowLayout {
                    visible: !usethemebackcolor.checked
                    Button {
                        text: i18n("Main color")
                        iconName: "org.kde.plasma.colorpicker"
                        tooltip: "Click to choose"
                        onClicked: {colorDialog.visible = true;}
                    }
                    TextField {
                        id: usercolor
                    }
                    
                }
        }
    }
    GroupBox {
        Layout.fillWidth: true
        title: i18n("Opacity")
        flat: true
        visible: userdefinedback.checked
            Slider {
                id:opacityslider
                minimumValue: 10
                maximumValue: 100
                stepSize: 10
                tickmarksEnabled: true
                
//                 value: 50
            }
    }
   
}
