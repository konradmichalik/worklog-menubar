import Foundation

enum WorklogBridge {
    static func scan(path: String, period: String, author: String?) -> [ProjectLog] {
        let result = path.withCString { pathPtr in
            period.withCString { periodPtr in
                if let author = author {
                    author.withCString { authorPtr in
                        worklog_scan(pathPtr, periodPtr, authorPtr)
                    }
                } else {
                    worklog_scan(pathPtr, periodPtr, nil)
                }
            }
        }

        guard let ptr = result else { return [] }
        defer { worklog_free_string(ptr) }

        let json = String(cString: ptr)
        let decoder = JSONDecoder()
        return (try? decoder.decode([ProjectLog].self, from: Data(json.utf8))) ?? []
    }

    static func defaultAuthor() -> String? {
        guard let ptr = worklog_default_author() else { return nil }
        defer { worklog_free_string(ptr) }
        return String(cString: ptr)
    }
}
