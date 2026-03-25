Class {
	#name : 'CIGSDL3PreSteps',
	#superclass : 'Object',
	#category : 'CIG-SDL3',
	#package : 'CIG-SDL3'
}

{ #category : 'steps' }
CIGSDL3PreSteps class >> step1Generate [
"This removes API subset that we may not want:

#define SDL_HIDAPI_DISABLED 1
#define SDL_hidapi_h_

#define SDL_HAPTIC_DISABLED 1
#define SDL_haptic_h_
"

	CigType typeMap at: 'wchar_t' put: #int.

	CigCLibraryGenerator new
		withoutBaseline;
		prefix: 'S3';
		packageName: 'SDL3';
		libraryName: 'SDL3';
		cIncludePath: 'SDL/include' asFileReference;
		cIncludePath: 'SDL/include/SDL3' asFileReference;
		importUnit: '
#define SDL_PLATFORM_LINUX 
#define SDL_PLATFORM_UNIX 
#define SDL_PLATFORM_MACOS
#define SDL_PLATFORM_IOS
#define SDL_PLATFORM_WINDOWS 
#define SDL_PLATFORM_WIN32

#define DOXYGEN_SHOULD_IGNORE_THIS
#define SDL_WIKI_DOCUMENTATION_SECTION
#define SDL_DISABLE_DLOPEN_NOTES

#define SDL_assert_h_

#include <SDL.h>
';
		withNameGenerator: [ :gen |
			gen stripPrefix: 'SDL_GUID' by: 'guid'.
			gen stripPrefix: 'SDL_GPU' by: 'gpu'.
			gen stripPrefix: 'SDL_UCS4' by: 'ucs4'.
			gen stripPrefix: 'SDL_IO' by: 'io'.

			gen stripPrefix: 'SDL_Metal_' by: 'metal'.
			gen stripPrefix: 'SDL_EGL_' by: 'egl'.
			gen stripPrefix: 'SDL_GL_' by: 'gl'.
			gen stripPrefix: 'SDL_'.

			gen stripPrefix: 'create' by: 'new'.
			];
		withElementGenerator: [ :gen | gen makeAllFunctionsReturningStringReturnPointer ];
		withConstantGenerator: [ :gen | 
			gen groupByRegexDictionary: {
				'SDL_ELF_NOTE_DLOPEN.*' -> 'DELETE'.

				'SDLK.*' -> 'Key'.
				'SDL_KMOD.*' -> 'KeyModifier'.
				'SDL_BUTTON.*' -> 'Button'.
				'SDL_HAPTIC.*' -> 'Haptic'.
				'SDL_HAT.*' -> 'Joystick'.
				'SDL_JOYSTICK_.*' -> 'Joystick'.

"				'SDL_ALPHA.*' -> 'Alpha'.
				'SDL_BLENDMODE.*' -> 'BlendMode'.
				'SDL_GL_CONTEXT.*' -> 'GLContext'.
				'SDL_GPU.*' -> 'Video'.
				'.*RENDERER.*' -> 'Video'.
"
				'SDL_ALPHA.*' -> 'Video'.
				'SDL_BLENDMODE.*' -> 'Video'.
				'SDL_GL_CONTEXT.*' -> 'Video'.
				'SDL_GPU.*' -> 'Video'.
				'.*RENDERER.*' -> 'Video'.
				'SDL_SURFACE.*' -> 'Video'.

				'SDL_HINT_ANDROID_.*' -> 'DELETE'.
				'SDL_HINT_APPLE_TV_.*' -> 'DELETE'.
				'SDL_HINT_PS2_.*' -> 'DELETE'.
				'SDL_HINT_VITA_.*' -> 'DELETE'.
"				'SDL_HINT_KMSDRM_.*' -> 'HintPlatform'.
				'SDL_HINT_MAC_.*' -> 'HintPlatform'.
				'SDL_HINT_WINDOWS_.*' -> 'HintPlatform'.
				'SDL_HINT_X11_.*' -> 'HintPlatform'.

				'SDL_HINT_AUDIO_.*' -> 'HintAudio'.
				'SDL_HINT_GAMECONTROLLER_.*' -> 'HintGameController'.
				'SDL_HINT_HIDAPI_.*' -> 'HintHIDAPI'.
				'SDL_HINT_JOYSTICK_.*' -> 'HintJoystick'.
				'SDL_HINT_MOUSE_.*' -> 'HintMouse'.
				'SDL_HINT_PEN_.*' -> 'HintPen'.
				'SDL_HINT_RENDER_.*' -> 'HintRender'.
				'SDL_HINT_VIDEO_.*' -> 'HintVideo'.
				'SDL_HINT_WAVE_.*' -> 'HintAudio'.
				'SDL_HINT_WINDOW.*' -> 'HintWindow'.
				'SDL_HINT.*' -> 'HintUncategorized'."
				'SDL_HINT.*' -> 'Hint'.
				
				'SDL_INIT.*' -> 'Init'.
				'SDL_MESSAGEBOX.*' -> 'MessageBox'.
				'SDL_TRAYENTRY.*' -> 'TrayEntry'.
				'SDL_WINDOW.*' -> 'Window'.

"				'SDL_PROP_APP_METADATA_.*' -> 'PropertyAppMetadata'.
				'SDL_PROP_DISPLAY_.*' -> 'PropertyDisplay'.
				'SDL_PROP_FILE_DIALOG_.*' -> 'PropertyFileDialog'.
				'SDL_PROP_GPU_.*' -> 'PropertyGPU'.
				'SDL_PROP_IOSTREAM_.*' -> 'PropertyIOStream'.
				'SDL_PROP_JOYSTICK_.*' -> 'PropertyJoystick'.
				'SDL_PROP_PROCESS_.*' -> 'PropertyProcess'.
				'SDL_PROP_SURFACE_.*' -> 'PropertySurface'.
				'SDL_PROP_TEXTINPUT.*' -> 'PropertyTextInput'.
				'SDL_PROP_TEXTURE_.*' -> 'PropertyTexture'.
				'SDL_PROP_THREAD_.*' -> 'PropertyThread'.
				'SDL_PROP_WINDOW_.*' -> 'PropertyWindow'.
				'SDL_PROP.*' -> 'PropertyUncategorized'."
				'SDL_PROP.*' -> 'Property'.
				
				'SDL_PRI.*' -> 'DELETE'.
				'.*_ENDIAN' -> 'Endian'.
				'.*_VERSION' -> 'Version'.
				'SDL_NS_.*|SDL_US_.*|SDL_MS_.*|SDL_SECONDS_.*' -> 'DELETE' "'Timer'"
			} asOrderedDictionary ifNone: 'DELETE' ];
		generate
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step2RenameClasses [
	"Unify prefixes and remove underscores"

	#(
	'S3SDL_'
	'S3SDL3'
	'S3SDL'
	'S3'
	) do: [ :oldPrefix |
			| renames |
			renames := Smalltalk allClassesAndTraits
				select: [ :each | each name beginsWith: oldPrefix ]
				thenCollect: [ :each |
					| newName |
					"Remove old prefix"
					newName := each name withoutPrefix: oldPrefix.

					"Convert underscores to CamelCase"
					newName := String streamContents: [ :writeStream | | readStream |
							readStream := newName readStream.
							[ readStream atEnd ] whileFalse: [
								writeStream nextPutAll: (readStream upTo: $_) capitalized ] ].

					"Add the new prefix"
					newName := 'SDL3', newName.

					each -> newName ].

		renames do: [ :each |
			Stdio stdout print: each; lf.
			(ReRenameClassRefactoring rename: each key name to: each value) execute ]	
		]
]

{ #category : 'steps' }
CIGSDL3PreSteps class >> step3DeleteClasses [

"	self environment allClasses select: [ :each |
		(each name beginsWith: 'SDL3') and: [
		each name includesSubstring: 'DELETE'] ]."

	(self environment at: #SDL3DELETEConstants) removeFromSystem
]
