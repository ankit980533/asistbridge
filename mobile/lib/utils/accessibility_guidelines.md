# Accessibility Guidelines for AssistBridge

## Design Principles for Visually Impaired Users

### 1. Voice Feedback
- Every screen announces itself when opened
- All buttons speak their purpose on long-press
- Actions provide voice confirmation (success/error)
- Status changes are announced automatically

### 2. Large Touch Targets
- Minimum button height: 70-100px
- Minimum touch target: 48x48dp
- Adequate spacing between interactive elements (16-24px)

### 3. Voice Input
- All text fields support voice input via microphone button
- Speech-to-text uses device's built-in recognition (free)
- Clear visual and audio feedback when listening

### 4. Screen Reader Support
- All elements have semantic labels
- Headers marked with `header: true`
- Live regions for dynamic content
- Proper focus order

### 5. Simplified Navigation
- Maximum 3-4 main actions per screen
- Step-by-step flows for complex tasks
- Clear back navigation
- Consistent layout across screens

### 6. High Contrast
- Primary colors with sufficient contrast ratio (4.5:1 minimum)
- Status colors are distinct and meaningful
- Text size minimum 16sp, headers 24sp+

### 7. Haptic Feedback
- Vibration on button taps
- Different vibration patterns for different actions
- Haptic feedback for errors

## Implementation Checklist

### Every Screen Must Have:
- [ ] Screen announcement on load
- [ ] Semantic labels on all interactive elements
- [ ] Large, clearly labeled buttons
- [ ] Voice feedback for actions
- [ ] High contrast colors

### Every Button Must Have:
- [ ] Minimum 70px height
- [ ] Clear text label
- [ ] Voice label for screen readers
- [ ] Voice hint explaining what it does
- [ ] Haptic feedback on tap

### Every Text Field Must Have:
- [ ] Voice input option
- [ ] Clear label
- [ ] Large font size (20sp+)
- [ ] Sufficient padding

## Testing

1. Enable TalkBack (Android) or VoiceOver (iOS)
2. Navigate entire app using only screen reader
3. Complete a full help request flow
4. Verify all announcements are clear and helpful
5. Test with eyes closed to simulate blindness
