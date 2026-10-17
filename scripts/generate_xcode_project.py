import os
import sys

def generate_pbxproj(output_path):
    # UUIDs: deterministic 24-char hex
    def u(val):
        return f"A1B2C3D4E5F6{val:012X}"

    # List of files
    core_files = [
        ("AIProvider.swift", "JarvisCore/Sources/JarvisCore/Providers/AIProvider.swift"),
        ("GeminiProvider.swift", "JarvisCore/Sources/JarvisCore/Providers/GeminiProvider.swift"),
        ("GroqProvider.swift", "JarvisCore/Sources/JarvisCore/Providers/GroqProvider.swift"),
        ("ProviderCatalog.swift", "JarvisCore/Sources/JarvisCore/Providers/ProviderCatalog.swift"),
        ("KeychainStore.swift", "JarvisCore/Sources/JarvisCore/Security/KeychainStore.swift"),
        ("MemoryStore.swift", "JarvisCore/Sources/JarvisCore/Memory/MemoryStore.swift"),
        ("ConversationContext.swift", "JarvisCore/Sources/JarvisCore/Memory/ConversationContext.swift"),
        ("SpeechEngine.swift", "JarvisCore/Sources/JarvisCore/Voice/SpeechEngine.swift"),
        ("VisemeEngine.swift", "JarvisCore/Sources/JarvisCore/Voice/VisemeEngine.swift"),
        ("AgentOrchestrator.swift", "JarvisCore/Sources/JarvisCore/Agent/AgentOrchestrator.swift"),
        ("ToolRegistry.swift", "JarvisCore/Sources/JarvisCore/Tools/ToolRegistry.swift"),
        ("ReminderManager.swift", "JarvisCore/Sources/JarvisCore/Reminders/ReminderManager.swift"),
    ]

    app_files = [
        ("JarvisApp.swift", "JarvisApp/App/JarvisApp.swift"),
        ("AppEnvironment.swift", "JarvisApp/App/AppEnvironment.swift"),
        ("RootView.swift", "JarvisApp/App/RootView.swift"),
        ("MainShell.swift", "JarvisApp/App/MainShell.swift"),
        ("JarvisTheme.swift", "JarvisApp/Design/JarvisTheme.swift"),
        ("JarvisFace.swift", "JarvisApp/Design/JarvisFace.swift"),
        ("WaveformView.swift", "JarvisApp/Design/WaveformView.swift"),
        ("JarvisComponents.swift", "JarvisApp/Design/JarvisComponents.swift"),
        ("AssistantHomeView.swift", "JarvisApp/Screens/AssistantHomeView.swift"),
        ("OnboardingView.swift", "JarvisApp/Screens/OnboardingView.swift"),
        ("MemoryCenterView.swift", "JarvisApp/Screens/MemoryCenterView.swift"),
        ("TasksView.swift", "JarvisApp/Screens/TasksView.swift"),
        ("IntegrationsView.swift", "JarvisApp/Screens/IntegrationsView.swift"),
        ("SettingsView.swift", "JarvisApp/Screens/SettingsView.swift"),
        ("ProviderSettingsView.swift", "JarvisApp/Screens/ProviderSettingsView.swift"),
        ("ConversationHistoryView.swift", "JarvisApp/Screens/ConversationHistoryView.swift"),
        ("DiagnosticsView.swift", "JarvisApp/Screens/DiagnosticsView.swift"),
    ]

    all_swift = core_files + app_files

    idx = 100
    file_refs = []
    build_files = []

    for name, path in all_swift:
        f_id = u(idx)
        b_id = u(idx + 1000)
        idx += 1
        file_refs.append(f'\t\t{f_id} /* {name} */ = {{isa = PBXFileReference; lastKnownFileType = sourcecode.swift; path = "{path}"; sourceTree = "<group>"; }};')
        build_files.append(f'\t\t{b_id} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {f_id} /* {name} */; }};')

    # Assets
    asset_fid = u(500)
    asset_bid = u(1500)
    file_refs.append(f'\t\t{asset_fid} /* Assets.xcassets */ = {{isa = PBXFileReference; lastKnownFileType = folder.assetcatalog; path = "JarvisApp/Resources/Assets.xcassets"; sourceTree = "<group>"; }};')
    build_files.append(f'\t\t{asset_bid} /* Assets.xcassets in Resources */ = {{isa = PBXBuildFile; fileRef = {asset_fid} /* Assets.xcassets */; }};')

    # Info.plist
    plist_fid = u(501)
    file_refs.append(f'\t\t{plist_fid} /* Info.plist */ = {{isa = PBXFileReference; lastKnownFileType = text.plist.xml; path = "JarvisApp/Info.plist"; sourceTree = "<group>"; }};')

    # Frameworks & Products
    product_fid = u(502)
    file_refs.append(f'\t\t{product_fid} /* JarvisApp.app */ = {{isa = PBXFileReference; explicitFileType = wrapper.application; includeInIndex = 0; path = JarvisApp.app; sourceTree = BUILT_PRODUCTS_DIR; }};')

    # Framework references
    frameworks = ["AVFoundation", "Speech", "UserNotifications", "Security", "EventKit"]
    framework_build_files = []
    for fw in frameworks:
        fw_fid = u(idx)
        fw_bid = u(idx + 1000)
        idx += 1
        file_refs.append(f'\t\t{fw_fid} /* {fw}.framework */ = {{isa = PBXFileReference; lastKnownFileType = wrapper.framework; name = {fw}.framework; path = System/Library/Frameworks/{fw}.framework; sourceTree = SDKROOT; }};')
        framework_build_files.append(f'\t\t{fw_bid} /* {fw}.framework in Frameworks */ = {{isa = PBXBuildFile; fileRef = {fw_fid} /* {fw}.framework */; }};')

    # Compile Sources Section
    sources_section = ",\n".join([f'\t\t\t\t{u(i + 1000)} /* {all_swift[i][0]} in Sources */' for i in range(len(all_swift))])

    # Resources Section
    resources_section = f'\t\t\t\t{asset_bid} /* Assets.xcassets in Resources */,'

    # Frameworks Section
    fw_section = ",\n".join([f'\t\t\t\t{u(idx - len(frameworks) + i + 1000)} /* {frameworks[i]}.framework in Frameworks */' for i in range(len(frameworks))])

    # All file ref IDs in main group
    group_children = ",\n".join([f'\t\t\t\t{u(100 + i)} /* {all_swift[i][0]} */' for i in range(len(all_swift))] + [
        f'\t\t\t\t{asset_fid} /* Assets.xcassets */',
        f'\t\t\t\t{plist_fid} /* Info.plist */',
    ])

    pbxproj_content = f"""// !$*UTF8*$!
{{
	archiveVersion = 1;
	classes = {{
	}};
	objectVersion = 56;
	objects = {{

/* Begin PBXBuildFile section */
{chr(10).join(build_files)}
{chr(10).join(framework_build_files)}
/* End PBXBuildFile section */

/* Begin PBXFileReference section */
{chr(10).join(file_refs)}
/* End PBXFileReference section */

/* Begin PBXFrameworksBuildPhase section */
		{u(1)} /* Frameworks */ = {{
			isa = PBXFrameworksBuildPhase;
			buildActionMask = 2147483647;
			files = (
{fw_section}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXFrameworksBuildPhase section */

/* Begin PBXGroup section */
		{u(2)} = {{
			isa = PBXGroup;
			children = (
{group_children},
				{product_fid} /* JarvisApp.app */,
			);
			sourceTree = "<group>";
		}};
/* End PBXGroup section */

/* Begin PBXNativeTarget section */
		{u(3)} /* JarvisApp */ = {{
			isa = PBXNativeTarget;
			buildConfigurationList = {u(4)} /* Build configuration list for PBXNativeTarget "JarvisApp" */;
			buildPhases = (
				{u(5)} /* Sources */,
				{u(1)} /* Frameworks */,
				{u(6)} /* Resources */,
			);
			buildRules = (
			);
			dependencies = (
			);
			name = JarvisApp;
			productName = JarvisApp;
			productReference = {product_fid} /* JarvisApp.app */;
			productType = "com.apple.product-type.application";
		}};
/* End PBXNativeTarget section */

/* Begin PBXProject section */
		{u(7)} /* Project object */ = {{
			isa = PBXProject;
			attributes = {{
				BuildIndependentTargetsInParallel = 1;
				LastSwiftUpdateCheck = 1540;
				LastUpgradeCheck = 1540;
				TargetAttributes = {{
					{u(3)} = {{
						CreatedOnToolsVersion = 15.4;
					}};
				}};
			}};
			buildConfigurationList = {u(8)} /* Build configuration list for PBXProject "JarvisApp" */;
			compatibilityVersion = "Xcode 14.0";
			developmentRegion = en;
			hasScannedForEncodings = 0;
			knownRegions = (
				en,
				Base,
			);
			mainGroup = {u(2)};
			productRefGroup = {u(2)};
			projectDirPath = "";
			projectRoot = "";
			targets = (
				{u(3)} /* JarvisApp */,
			);
		}};
/* End PBXProject section */

/* Begin PBXResourcesBuildPhase section */
		{u(6)} /* Resources */ = {{
			isa = PBXResourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{resources_section}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXResourcesBuildPhase section */

/* Begin PBXSourcesBuildPhase section */
		{u(5)} /* Sources */ = {{
			isa = PBXSourcesBuildPhase;
			buildActionMask = 2147483647;
			files = (
{sources_section}
			);
			runOnlyForDeploymentPostprocessing = 0;
		}};
/* End PBXSourcesBuildPhase section */

/* Begin XCBuildConfiguration section */
		{u(10)} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = dwarf;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				ENABLE_TESTABILITY = YES;
				GCC_DYNAMIC_NO_PIC = NO;
				GCC_NO_COMMON_BLOCKS = YES;
				GCC_OPTIMIZATION_LEVEL = 0;
				GCC_PREPROCESSOR_DEFINITIONS = (
					"DEBUG=1",
					"$(inherited)",
				);
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;
				ONLY_ACTIVE_ARCH = YES;
				SDKROOT = iphoneos;
				SWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;
				SWIFT_OPTIMIZATION_LEVEL = "-Onone";
			}};
			name = Debug;
		}};
		{u(11)} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ALWAYS_SEARCH_USER_PATHS = NO;
				CLANG_ANALYZER_NONNULL = YES;
				CLANG_ENABLE_MODULES = YES;
				CLANG_ENABLE_OBJC_ARC = YES;
				COPY_PHASE_STRIP = NO;
				DEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";
				ENABLE_NS_ASSERTIONS = NO;
				ENABLE_STRICT_OBJC_MSGSEND = YES;
				GCC_NO_COMMON_BLOCKS = YES;
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				MTL_ENABLE_DEBUG_INFO = NO;
				SDKROOT = iphoneos;
				SWIFT_COMPILATION_MODE = wholemodule;
				SWIFT_OPTIMIZATION_LEVEL = "-O";
				VALIDATE_PRODUCT = YES;
			}};
			name = Release;
		}};
		{u(12)} /* Debug */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_IDENTITY = "";
				CODE_SIGNING_ALLOWED = NO;
				CODE_SIGNING_REQUIRED = NO;
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "JarvisApp/Info.plist";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = ai.jarvis.next;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Debug;
		}};
		{u(13)} /* Release */ = {{
			isa = XCBuildConfiguration;
			buildSettings = {{
				ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon;
				ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME = AccentColor;
				CODE_SIGN_IDENTITY = "";
				CODE_SIGNING_ALLOWED = NO;
				CODE_SIGNING_REQUIRED = NO;
				CURRENT_PROJECT_VERSION = 1;
				ENABLE_PREVIEWS = YES;
				GENERATE_INFOPLIST_FILE = NO;
				INFOPLIST_FILE = "JarvisApp/Info.plist";
				IPHONEOS_DEPLOYMENT_TARGET = 17.0;
				LD_RUNPATH_SEARCH_PATHS = (
					"$(inherited)",
					"@executable_path/Frameworks",
				);
				MARKETING_VERSION = 1.0.0;
				PRODUCT_BUNDLE_IDENTIFIER = ai.jarvis.next;
				PRODUCT_NAME = "$(TARGET_NAME)";
				SWIFT_EMIT_LOC_STRINGS = YES;
				SWIFT_VERSION = 5.0;
				TARGETED_DEVICE_FAMILY = "1,2";
			}};
			name = Release;
		}};
/* End XCBuildConfiguration section */

/* Begin XCConfigurationList section */
		{u(8)} /* Build configuration list for PBXProject "JarvisApp" */;
		{u(8)} = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{u(10)} /* Debug */,
				{u(11)} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
		{u(4)} /* Build configuration list for PBXNativeTarget "JarvisApp" */;
		{u(4)} = {{
			isa = XCConfigurationList;
			buildConfigurations = (
				{u(12)} /* Debug */,
				{u(13)} /* Release */,
			);
			defaultConfigurationIsVisible = 0;
			defaultConfigurationName = Release;
		}};
/* End XCConfigurationList section */

	}};
	rootObject = {u(7)} /* Project object */;
}}
"""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)
    with open(output_path, "w", encoding="utf-8") as f:
        f.write(pbxproj_content)
    print(f"Generated {output_path} with {len(all_swift)} Swift sources.")

if __name__ == "__main__":
    out = sys.argv[1] if len(sys.argv) > 1 else "ios/JarvisApp.xcodeproj/project.pbxproj"
    generate_pbxproj(out)
