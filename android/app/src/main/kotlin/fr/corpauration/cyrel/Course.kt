package fr.corpauration.cyrel

import android.os.Parcel
import android.os.Parcelable
import javax.security.auth.Subject

class Course private constructor(`in`: Parcel): Parcelable {
    private var id: String? = `in`.readString()
    private var start: String? = `in`.readString()
    private var end: String? = `in`.readString()
    private var category: Int = `in`.readInt()
    var subject: String? = `in`.readString()
    private var teachers: String? = `in`.readString()
    private var rooms: String? = `in`.readString()

    constructor(id: String, start: String, end: String?, category: Int, subject: String?, teachers: String, rooms: String) : this(Parcel.obtain()) {
        this.id = id
        this.start = start
        this.end = end
        this.category = category
        this.subject = subject
        this.teachers = teachers
        this.rooms = rooms
    }

    override fun writeToParcel(parcel: Parcel, flags: Int) {
        parcel.writeString(id)
        parcel.writeString(start)
        parcel.writeString(end)
        parcel.writeInt(category)
        parcel.writeString(subject)
        parcel.writeString(teachers)
        parcel.writeString(rooms)
    }

    override fun describeContents(): Int {
        return 0
    }

    companion object CREATOR : Parcelable.Creator<Course> {
        override fun createFromParcel(parcel: Parcel): Course {
            return Course(parcel)
        }

        override fun newArray(size: Int): Array<Course?> {
            return arrayOfNulls(size)
        }
    }
}
