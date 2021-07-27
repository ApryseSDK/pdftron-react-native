import Config from "./Config";

type ValueOf<T> = T[keyof T];

export type Buttons = ValueOf<Config.Buttons>;
export type Tools = ValueOf<Config.Tools>;
export type FitMode = ValueOf<Config.FitMode>;
export type LayoutMode = ValueOf<Config.LayoutMode>;
export type FieldFlags = ValueOf<Config.FieldFlags>;
export type AnnotationMenu = ValueOf<Config.AnnotationMenu>;
export type EraserType = ValueOf<Config.EraserType>;
export type LongPressMenu = ValueOf<Config.LongPressMenu>;
export type Actions = ValueOf<Config.Actions>;
export type AnnotationFlags = ValueOf<Config.AnnotationFlags>;
export type DefaultToolbars = ValueOf<Config.DefaultToolbars>;
export type ToolbarIcons = ValueOf<Config.ToolbarIcons>;
export type CustomToolbarKey = ValueOf<Config.CustomToolbarKey>;
export type ThumbnailFilterMode = ValueOf<Config.ThumbnailFilterMode>;
export type Conversion = ValueOf<Config.Conversion>;
export type ViewModePickerItem = ValueOf<Config.ViewModePickerItem>;
export type ZoomLimitMode = ValueOf<Config.ZoomLimitMode>;
export type OverprintMode = ValueOf<Config.OverprintMode>;
export type ColorPostProcessMode = ValueOf<Config.ColorPostProcessMode>;
export type ReflowOrientation = ValueOf<Config.ReflowOrientation>;
export type ExportFormat = ValueOf<Config.ExportFormat>;