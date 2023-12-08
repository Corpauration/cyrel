package fr.corpauration.cyrel

data class CourseEntity(
    val id: String,
    val start: String,
    val startT: Long,
    val end: String?,
    val endT: Long?,
    val category: Int,
    val subject: String?,
    val teachers: String,
    val rooms: String
)
