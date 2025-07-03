import React from 'react';
import { render } from '@testing-library/react-native';
import Page from '../app/index';
import { images } from '../app/images';

// Mock dependencies
jest.mock('../app/images', () => ({
  images: {
    logo: 'logo-source',
  },
}));

jest.mock('react-native', () => ({
  View: ({ children, className, ...props }: any) => (
    <div testID='view' data-classname={className} {...props}>
      {children}
    </div>
  ),
  Text: ({ children, className, role, ...props }: any) => (
    <span testID='text' data-classname={className} data-role={role} {...props}>
      {children}
    </span>
  ),
  Image: ({ source, className, ...props }: any) => (
    <img
      testID='image'
      data-source={source}
      data-classname={className}
      {...props}
    />
  ),
}));

describe('Index Page', () => {
  describe('Component Rendering', () => {
    it('renders without crashing', () => {
      const { getAllByTestId } = render(<Page />);

      expect(getAllByTestId('view')).toBeTruthy();
    });

    it('displays the main title', () => {
      const { getByText } = render(<Page />);

      const title = getByText('Writer');
      expect(title).toBeTruthy();
      expect(title.props['data-role']).toBe('heading');
    });

    it('displays the app description', () => {
      const { getByText } = render(<Page />);

      const description = getByText(
        'This app is a very personal helper for novel author. It will allow you sync with a GitHub repository, then you can use local TTS service to read content of files.'
      );
      expect(description).toBeTruthy();
    });

    it('displays the app logo', () => {
      const { getByTestId } = render(<Page />);

      const logo = getByTestId('image');
      expect(logo).toBeTruthy();
      expect(logo.props['data-source']).toBe('logo-source');
    });
  });

  describe('Multilingual Quotes', () => {
    it('displays Chinese quote', () => {
      const { getByText } = render(<Page />);

      expect(getByText('兼听则明')).toBeTruthy();
    });

    it('displays English quote', () => {
      const { getByText } = render(<Page />);

      expect(getByText('Listening is the beginning of wisdom')).toBeTruthy();
    });

    it('displays Greek quote', () => {
      const { getByText } = render(<Page />);

      expect(
        getByText('Διότι η σοφία αρχίζει από την περιέργεια')
      ).toBeTruthy();
    });

    it('displays Latin quote', () => {
      const { getByText } = render(<Page />);

      expect(getByText('Auditus est initium sapientiae')).toBeTruthy();
    });

    it('displays German quote', () => {
      const { getByText } = render(<Page />);

      expect(getByText('Das Zuhören ist der Anfang der Weisheit')).toBeTruthy();
    });

    it('displays Spanish quote', () => {
      const { getByText } = render(<Page />);

      expect(getByText('Escuchar es el comienzo de la sabiduría')).toBeTruthy();
    });
  });

  describe('Styling Classes', () => {
    it('applies correct styling to main container', () => {
      const { getAllByTestId } = render(<Page />);

      const views = getAllByTestId('view');
      const mainContainer = views[0];
      expect(mainContainer.props['data-classname']).toBe(
        'flex-1 bg-white dark:bg-black'
      );
    });

    it('applies correct styling to title', () => {
      const { getByText } = render(<Page />);

      const title = getByText('Writer');
      expect(title.props['data-classname']).toContain(
        'text-black dark:text-white'
      );
      expect(title.props['data-classname']).toContain('text-2xl');
      expect(title.props['data-classname']).toContain('font-bold');
    });

    it('applies correct styling to description', () => {
      const { getByText } = render(<Page />);

      const description = getByText(
        'This app is a very personal helper for novel author. It will allow you sync with a GitHub repository, then you can use local TTS service to read content of files.'
      );
      expect(description.props['data-classname']).toContain('text-gray-500');
      expect(description.props['data-classname']).toContain(
        'dark:text-gray-400'
      );
    });

    it('applies correct styling to multilingual quotes', () => {
      const { getByText } = render(<Page />);

      const chineseQuote = getByText('兼听则明');
      expect(chineseQuote.props['data-classname']).toContain('text-gray-700');
      expect(chineseQuote.props['data-classname']).toContain(
        'dark:text-gray-200'
      );
      expect(chineseQuote.props['data-classname']).toContain('text-2xl');
    });

    it('applies correct styling to logo', () => {
      const { getByTestId } = render(<Page />);

      const logo = getByTestId('image');
      expect(logo.props['data-classname']).toContain('w-16 h-16');
      expect(logo.props['data-classname']).toContain('rounded-2xl');
    });
  });

  describe('Layout Structure', () => {
    it('has proper nested view structure', () => {
      const { getAllByTestId } = render(<Page />);

      const views = getAllByTestId('view');
      expect(views.length).toBeGreaterThan(1);
    });

    it('contains all required text elements', () => {
      const { getAllByTestId } = render(<Page />);

      const texts = getAllByTestId('text');
      // Should have title + description + 6 multilingual quotes = 8 text elements
      expect(texts.length).toBe(8);
    });

    it('contains image element', () => {
      const { getAllByTestId } = render(<Page />);

      const images = getAllByTestId('image');
      expect(images.length).toBe(1);
    });
  });

  describe('Content Verification', () => {
    it('displays all expected content elements', () => {
      const { getByText, getByTestId } = render(<Page />);

      // Check title
      expect(getByText('Writer')).toBeTruthy();

      // Check description
      expect(getByText(/This app is a very personal helper/)).toBeTruthy();

      // Check all quotes are present
      expect(getByText('兼听则明')).toBeTruthy();
      expect(getByText('Listening is the beginning of wisdom')).toBeTruthy();
      expect(
        getByText('Διότι η σοφία αρχίζει από την περιέργεια')
      ).toBeTruthy();
      expect(getByText('Auditus est initium sapientiae')).toBeTruthy();
      expect(getByText('Das Zuhören ist der Anfang der Weisheit')).toBeTruthy();
      expect(getByText('Escuchar es el comienzo de la sabiduría')).toBeTruthy();

      // Check logo
      expect(getByTestId('image')).toBeTruthy();
    });
  });

  describe('Accessibility', () => {
    it('sets proper heading role for title', () => {
      const { getByText } = render(<Page />);

      const title = getByText('Writer');
      expect(title.props['data-role']).toBe('heading');
    });

    it('provides meaningful text content', () => {
      const { getByText } = render(<Page />);

      // Check that description is informative
      const description = getByText(/This app is a very personal helper/);
      expect(description.props.children).toContain('GitHub repository');
      expect(description.props.children).toContain('TTS service');
    });
  });

  describe('Responsive Design Classes', () => {
    it('includes responsive classes for different screen sizes', () => {
      const { getByText } = render(<Page />);

      const title = getByText('Writer');
      const titleClasses = title.props['data-classname'];

      // Check for responsive text sizing
      expect(titleClasses).toContain('native:text-5xl');
      expect(titleClasses).toContain('sm:text-4xl');
      expect(titleClasses).toContain('md:text-5xl');
      expect(titleClasses).toContain('lg:text-6xl');
    });

    it('includes responsive padding classes', () => {
      const { getAllByTestId } = render(<Page />);

      const views = getAllByTestId('view');
      const paddingView = views.find((view) =>
        view.props['data-classname']?.includes('py-12')
      );

      expect(paddingView).toBeTruthy();
      expect(paddingView.props['data-classname']).toContain('md:py-24');
      expect(paddingView.props['data-classname']).toContain('lg:py-32');
      expect(paddingView.props['data-classname']).toContain('xl:py-48');
    });
  });

  describe('Theme Support', () => {
    it('includes dark mode classes', () => {
      const { getByText, getAllByTestId } = render(<Page />);

      // Check main container
      const views = getAllByTestId('view');
      const mainContainer = views[0];
      expect(mainContainer.props['data-classname']).toContain('dark:bg-black');

      // Check title
      const title = getByText('Writer');
      expect(title.props['data-classname']).toContain('dark:text-white');

      // Check description
      const description = getByText(/This app is a very personal helper/);
      expect(description.props['data-classname']).toContain(
        'dark:text-gray-400'
      );
    });
  });

  describe('Image Integration', () => {
    it('uses correct image source from images module', () => {
      const { getByTestId } = render(<Page />);

      const logo = getByTestId('image');
      expect(logo.props['data-source']).toBe(images.logo);
    });
  });
});
