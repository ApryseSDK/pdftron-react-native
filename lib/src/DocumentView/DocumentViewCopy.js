import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';
import { requireNativeComponent, ViewPropTypes, Platform, NativeModules, findNodeHandle, } from 'react-native';
const { DocumentViewManager } = NativeModules;
import { Config } from "../Config/Config";
/**
 * Object containing PropTypes types for {@link DocumentView} class.
 * Also used to generate prop types for TS users.
 *
 * To represent functions, please use {@link func}.
 * To represent "one of Config.Buttons values" or "an array of
 * Config.Buttons values", please use {@link oneOf} or {@link arrayOf}.
 */
const propTypes = {
    document: PropTypes.string.isRequired,
    password: PropTypes.string,
    initialPageNumber: PropTypes.number,
    // Any Config.FitMode constant.
    fitMode: oneOf(Config.FitMode),
    // Array of Config.Tools constants.
    disabledTools: arrayOf(Config.Tools),
    // A function with parameter "path" of type string.
    onDocumentLoaded: func(),
    ...ViewPropTypes,
};
/**
* Creates a custom PropType for functions.
*
* If the resulting PropType is used to generate prop types for TS users,
* type checking for function parameters and return values will be provided.
* @returns {Requireable<T>} A custom PropType constant.
* @example
* func<(path: string) => void>()
*/
function func() {
    let validator = function (props, propName, componentName, location, propFullName) {
        if (typeof props[propName] !== "function" && typeof props[propName] !== "undefined") {
            return new Error(`Invalid prop \`${propName}\` of type \`${typeof props[propName]}\` supplied to \`${componentName}\`, expected a function.`);
        }
        return null;
    };
    const t = validator;
    t.isRequired = validator;
    return t;
}
/**
 * Creates a custom PropType representing any value from given object(s).
 * @param {object} obj An object containing values.
 * @param {...object} rest Indefinite number of other objects containing values.
 * @returns {Requireable<T>} A custom PropType constant.
 * @example
 * oneOf<Config.Tools>(Config.Tools)
 * oneOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons)
*/
function oneOf(obj, ...rest) {
    if (rest.length > 0) {
        return PropTypes.oneOf(Object.values(Object.assign({}, obj, ...rest)));
    }
    return PropTypes.oneOf(Object.values(obj));
}
/**
 * Creates a custom PropType representing any array containing values from given object(s).
 * @param {object} obj An object containing values.
 * @param {...object} rest Indefinite number of other objects containing values.
 * @returns {Requireable<T[]>} A custom PropType constant.
 * @example
 * arrayOf<Config.Tools>(Config.Tools)
 * arrayOf<Config.Tools | Config.Buttons>(Config.Tools, Config.Buttons)
*/
function arrayOf(obj, ...rest) {
    return PropTypes.arrayOf(oneOf(obj, ...rest));
}
export class DocumentView extends PureComponent {
    _viewerRef;
    static propTypes = propTypes;
    onChange = (event) => {
        // other event listeners
        if (event.nativeEvent.onDocumentLoaded) {
            if (this.props.onDocumentLoaded) {
                this.props.onDocumentLoaded(event.nativeEvent.onDocumentLoaded);
            }
        }
    };
    // Methods
    /**
     * Selects the text within the given rectangle region.
     * @param rect the rectangle region in the format of x1: number, y1: number, x2: number, y2: number
     * @returns bool; whether there is text selected
     */
    selectInRect = (rect) => {
        const tag = findNodeHandle(this._viewerRef);
        if (tag != null) {
            return DocumentViewManager.selectInRect(tag, rect);
        }
        return Promise.resolve();
    };
    _setNativeRef = (ref) => {
        this._viewerRef = ref;
    };
    render() {
        return (
        // @ts-ignore
        <RCTDocumentView ref={this._setNativeRef} style={{ flex: 1 }} 
        // @ts-ignore: Intentionally exclude `onChange` from being exposed as a prop.
        onChange={this.onChange} {...this.props}/>);
    }
}
const name = Platform.OS === 'ios' ? 'RNTPTDocumentView' : 'RCTDocumentView';
const RCTDocumentView = requireNativeComponent(name);
