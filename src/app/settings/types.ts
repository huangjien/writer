export interface SettingsFormData {
  githubRepo: string;
  githubToken: string;
  contentFolder: string;
  analysisFolder: string;
  fontSize: number;
  backgroundImage: string;
  progress: number;
  current: string;
}

export interface FieldComponentProps {
  control: any;
  errors: any;
}

export interface FontSizeFieldProps extends FieldComponentProps {
  selectedIndex: number;
  setSelectedIndex: (index: number) => void;
  setValue: (name: string, value: any) => void;
}

export interface CurrentReadingFieldProps {
  control: any;
  getValues: (names?: string | string[]) => any;
}

export interface ReadingProgressFieldProps {
  control: any;
  getProgressPercentage: () => string;
}

export interface UseSettingsFormReturn {
  control: any;
  handleSubmit: (
    callback: (data: any) => void
  ) => (e?: React.BaseSyntheticEvent) => Promise<void>;
  setValue: (name: string, value: any) => void;
  getValues: (names?: string | string[]) => any;
  errors: any;
  selectedIndex: number;
  setSelectedIndex: (index: number) => void;
  isFocused: boolean;
  setItem: (key: string, value: string) => Promise<void>;
  getItem: (key: string) => Promise<string | null>;
}

export interface SettingsUtilsParams {
  getItem: (key: string) => Promise<string | null>;
  setItem: (key: string, value: string) => Promise<void>;
  setValue: (name: string, value: any) => void;
  setSelectedIndex: (index: number) => void;
  getValues: (names?: string | string[]) => any;
}
