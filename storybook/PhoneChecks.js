.pragma library

// What wouldn't work on a phone in an item tree: parts reaching past the
// root's sides, and tappable parts smaller than a fingertip. The storybook's
// Preview window marks them; tests/tst_PhoneFit.qml fails on them.

// find(root, minTarget) -> { overflow: [items], small: [items] }
function find(root, minTarget) {
    const found = { overflow: [], small: [] }
    walk(root, root, false, false, minTarget, found)
    return found
}

// A part past the edge of a clipping item can't be seen, so isn't checked;
// its scrolling is the clipping item's business. Of parts that reach past,
// only the outermost is listed. A field inside a control, such as a search
// bar's or a spin box's, has the control as its target.
function walk(root, item, clipped, inControl, minTarget, found) {
    for (let i = 0; i < item.children.length; ++i) {
        const child = item.children[i]
        if (!child.visible || child.opacity === 0)
            continue
        let past = false
        if (child.width > 0 && child.height > 0) {
            const left = child.mapToItem(root, 0, 0).x
            past = !clipped && (left < -0.5 || left + child.width > root.width + 0.5)
            if (past)
                found.overflow.push(child)
            if (tappable(child, inControl) && (child.width < minTarget - 0.5 || child.height < minTarget - 0.5))
                found.small.push(child)
        }
        walk(root, child, clipped || past || child.clip, inControl || isControl(child), minTarget, found)
    }
}

// Buttons and everything like them, editable fields, mouse areas and items
// with a tap handler, while they take a tap.
function tappable(item, inControl) {
    if (!item.enabled)
        return false
    const button = "checkable" in item && "autoExclusive" in item && "pressed" in item
    const mouseArea = "acceptedButtons" in item && "pressed" in item && item.acceptedButtons !== 0
    const field = "echoMode" in item && "cursorPosition" in item && !item.readOnly && !inControl
    return button || mouseArea || field || hasTapHandler(item)
}

function isControl(item) {
    return "contentItem" in item && "focusPolicy" in item
}

function hasTapHandler(item) {
    for (let i = 0; i < item.data.length; ++i) {
        const handler = item.data[i]
        if (handler && "gesturePolicy" in handler && "tapCount" in handler && handler.enabled)
            return true
    }
    return false
}

// "LogosButton "Save" 32×32 at 10,4", for a failure message or a tooltip.
function describe(item, root) {
    const type = String(item).replace(/_QMLTYPE_\d+|_QML_\d+|\(0x[0-9a-f]+\)/g, "").trim()
    const text = typeof item.text === "string" && item.text !== "" ? " \"" + item.text + "\"" : ""
    const at = item.mapToItem(root, 0, 0)
    return type + text + " " + Math.round(item.width) + "×" + Math.round(item.height)
           + " at " + Math.round(at.x) + "," + Math.round(at.y)
}
