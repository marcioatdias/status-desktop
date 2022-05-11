import QtQuick 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Controls 0.1

/*!
    \qmltype StatusImageCropPanel
    \inherits Item
    \inqmlmodule StatusQ.Components
    \since StatusQ.Components 0.1
    \brief Draw a crop-window onto an image and allows manipulating the position of the crop-window. Inherits \l{https://doc.qt.io/qt-5/qml-qtquick-item.html}{Item}.

    Adds mouse pan and zoom functionality on top of StatusImageCrop functionality. Also adds small
    practical features and optimizes drawing by minimizing StatusImageCrop area

    \sa StatusImageCrop for more details

    Example of how to use it:

    \qml
        StatusImageCropPanel {
            width: 400
            height: 200
            source: "qrc:/demoapp/data/logo-test-image.png"
            windowStyle: StatusImageCrop.WindowStyle.Rectangular
            Component.onCompleted: setCropRect(Qt.rect(10, 0, sourceSize.width - 20, sourceSize.height))
        }
    \endqml

    For a list of components available see StatusQ.
*/
Item {
    id: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    /*!
        \qmlproperty real StatusImageCrop::aspectRatio
        Initial aspect-ratio of the crop-window
    */
    property real aspectRatio: 1
    /*!
        \qmlproperty bool StatusImageCrop::interactive
        If true allows user to interact with the image. Set to false for previewing existing crop-data
    */
    property bool interactive: true
    /*!
        \qmlproperty bool StatusImageCrop::margins
        Space to keep around the control borders and crop area
    */
    property int margins: 10

    /*!
        \qmlproperty url StatusImageCropPanel::source
        \sa StatusImageCrop::source
    */
    /*required*/ property alias source: cropEditor.source

    /*!
        \qmlproperty WindowStyle StatusImageCropPanel::windowStyle
        \sa StatusImageCrop::windowStyle
    */
    property alias windowStyle: cropEditor.windowStyle
    /*!
        \qmlproperty int StatusImageCropPanel::radius
        \sa StatusImageCrop::radius
    */
    property alias radius: cropEditor.radius
    /*!
        \qmlproperty color StatusImageCropPanel::wallColor
        \sa StatusImageCrop::wallColor
    */
    property alias wallColor: cropEditor.wallColor
    /*!
        \qmlproperty real StatusImageCropPanel::wallTransparency
        \sa StatusImageCrop::wallTransparency
    */
    property alias wallTransparency: cropEditor.wallTransparency
    /*!
        \qmlproperty rect StatusImageCropPanel::cropRect
        \sa StatusImageCrop::cropRect
    */
    property alias cropRect: cropEditor.cropRect
    /*!
        \qmlproperty rect StatusImageCropPanel::cropRect
        \sa StatusImageCrop::cropRect
    */
    readonly property alias cropWindow: cropEditor.cropWindow
    /*!
        \qmlproperty real StatusImageCrop::scrollZoomFactor
        How fast is image scaled (zoomed) when using mouse scroll
    */
    property real scrollZoomFactor: 0.5
    /*!
        \qmlproperty bool StatusImageCropPanel::enableCheckers
        Shows helper guiding checkers pattern where image is not covering
    */
    property bool enableCheckers: root.interactive
    /*!
        \qmlproperty size StatusImageCropPanel::sourceSize
        \sa StatusImageCrop::sourceSize
    */
    property alias sourceSize: cropEditor.sourceSize

    /*
        \qmlmethod StatusImageCropPanel::setCropRect(rect)
        \sa StatusImageCrop::cropRect
    */
    function setCropRect(newRect) {
        cropEditor.setCropRect(newRect)
        aspectRatio = cropEditor.aspectRatio
    }

    QtObject {
        id: d

        function updateAspectRatio(newAR) {
            // Keep width and adjust height
            const eW = cropEditor.cropRect.width
            const w = (eW <= 0) ? cropEditor.sourceSize.width : eW
            const h = w/newAR
            const c = (eW <= 0)
                    ? Qt.point(cropEditor.sourceSize.width/2, cropEditor.sourceSize.height/2)
                    : Qt.point(cropEditor.cropRect.x + w/2, cropEditor.cropRect.y + cropEditor.cropRect.height/2)
            const nR = Qt.rect(c.x - w/2, c.y-h/2, w, h)
            cropEditor.setCropRect(nR)
        }
    }

    Component.onCompleted: d.updateAspectRatio(root.aspectRatio)
    onAspectRatioChanged: d.updateAspectRatio(root.aspectRatio)
    onSourceSizeChanged: d.updateAspectRatio(root.aspectRatio)

    ColumnLayout {
        id: mainLayout

        anchors.fill: parent

        Item {
            id: cropSpaceItem

            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            Rectangle {
                id: leftOverlay
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.right: cropEditor.left
                anchors.bottom: parent.bottom
                color: wallColor
                opacity: wallTransparency
                z: cropEditor.z + 1
            }
            Rectangle {
                id: topOverlay
                anchors.left: leftOverlay.right
                anchors.top: parent.top
                anchors.right: rightOverlay.left
                anchors.bottom: cropEditor.top
                color: wallColor
                opacity: wallTransparency
                z: cropEditor.z + 1
            }

            StatusImageCrop {
                id: cropEditor
                anchors.centerIn: parent
                width: aspectRatio < cropSpaceItem.width/cropSpaceItem.height ? cropSpaceItem.height * aspectRatio : cropSpaceItem.width - root.margins * 2
                height: aspectRatio < cropSpaceItem.width/cropSpaceItem.height ? cropSpaceItem.height - root.margins * 2 : cropSpaceItem.width / aspectRatio
            }

            Rectangle {
                id: rightOverlay
                anchors.left: cropEditor.right
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                color: wallColor
                opacity: wallTransparency
                z: cropEditor.z + 1
            }

            Rectangle {
                id: bottomOverlay
                anchors.left: leftOverlay.right
                anchors.top: cropEditor.bottom
                anchors.right: rightOverlay.left
                anchors.bottom: parent.bottom
                color: wallColor
                opacity: wallTransparency
                z: cropEditor.z + 1
            }

            // Checkers
            Canvas {
                visible: root.enableCheckers
                anchors.fill: parent
                onPaint: {
                    var ctx = getContext("2d")
                    for(let xI = 0; xI < Math.ceil(width/10); xI++) {
                        for(let yI = 0; yI < Math.ceil(height/10); yI++) {
                            ctx.fillStyle = (xI % 2) === (yI % 2) ? "#FFFFFE" : "#DBDBDB"
                            ctx.fillRect(xI * 10, yI * 10, 10, 10)
                        }
                    }
                }
                z: cropEditor.z - 1
            }

            // Drag and zoom
            MouseArea {
                anchors.fill: parent

                enabled: root.interactive

                property var lastDragPoint: null
                onReleased: lastDragPoint = null

                onMouseXChanged: updateDrag(Qt.point(mouse.x, mouse.y))
                onMouseYChanged: updateDrag(Qt.point(mouse.x, mouse.y))

                onWheel: {
                    const delta = wheel.angleDelta.y / 120
                    cropEditor.setCropRect(cropEditor.getZoomRect(cropEditor.zoomScale + delta * root.scrollZoomFactor))
                }

                function moveRect(r /*rect*/, delta /*real*/) {
                    return Qt.rect(r.x + delta.x, r.y + delta.y, r.width, r.height)
                }

                function scaleSize(sz /*size*/, s /*size*/) {
                    return Qt.point(sz.width * s, sz.height * s)
                }

                function updateDrag(p) {
                    let delta = (lastDragPoint ? Qt.size(lastDragPoint.x - p.x, lastDragPoint.y - p.y) : Qt.size(0, 0))
                    delta = scaleSize(delta, 1/cropEditor.scrToImgScale)
                    cropEditor.setCropRect(moveRect(cropEditor.cropRect, delta))
                    lastDragPoint = p
                }
            }
        }

        RowLayout {
            visible: root.interactive

            StatusIcon {
                icon: "remove-circle"

                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
            StatusSlider {
                Layout.fillWidth: true
                Layout.topMargin: 20
                Layout.bottomMargin: 25
                Layout.alignment: Qt.AlignVCenter

                enabled: root.interactive

                from: cropEditor.minZoomScale
                to: cropEditor.maxZoomScale
                value: cropEditor.zoomScale
                live: false
                onMoved: cropEditor.setCropRect(cropEditor.getZoomRect(valueAt(visualPosition)))
            }
            StatusIcon {
                icon: "add-circle"

                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
            }
        }
    }
}

