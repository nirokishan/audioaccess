/*
 * This Kotlin source file was generated by the Gradle 'init' task.
 */
package audio_access

import org.gradle.testfixtures.ProjectBuilder
import kotlin.test.Test
import kotlin.test.assertNotNull

/**
 * A simple unit test for the 'audio_access.greeting' plugin.
 */
class Audio_accessPluginTest {
    @Test fun `plugin registers task`() {
        // Create a test project and apply the plugin
        val project = ProjectBuilder.builder().build()
        project.plugins.apply("audio_access.greeting")

        // Verify the result
        assertNotNull(project.tasks.findByName("greeting"))
    }
}