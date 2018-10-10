# Foil

A simple image editor component for cocoa.

![Screenshot](Docs/screenshot-1.png)

## How to install 

Using [Carthage](https://github.com/Carthage/Carthage), add the following to your `Cartfile`:

`github "marcoconti83/Foil"`

## How to use

Use `ImageEditorViewController`, a `NSViewController`, to display the canvas and a toolbar. If you want more control, you can instead use `ImageEditView`, a `NSView`, but you have to handle tool selection and zoom/panning on your own.

To get the resulting image, use the `image` property of either the `ImageEditorViewController` or the `ImageEditView` you are using.

When creating an `ImageEditorViewController`, you should use `init(settings:)`. The settings can be used to controll which predefined bitmaps are available, and whether the user is allowed to pick more bitmaps from the filesystem. 

### Layers

The image editor has different layers, which can not be manually selected. The layer that is affected by an operation is defined by the tool that is used.

The layers are:

- Background color: This is a solid-color uniform layer. Change the color with `ImageLayers.backgroundColor`
- Background image: This is an optional image drawn above the background color. If the ratio of the background image differs from the size of the canvas (set at creation time), the background image will be stretched to fit.
- Raster layer: This layer is affected by the line, brush and eraser tool. Therefore, erasing will only affect this layer, not the background image not bitmaps.
- Bitmaps: This layer contails images that are inserted as "stickers". These images can be selected, scaled and deleted and are not affected by the eraser.

