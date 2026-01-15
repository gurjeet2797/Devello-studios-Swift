import Foundation
import Supabase

struct SupabaseStorageService {
    let client: SupabaseClient

    func uploadImage(
        data: Data,
        contentType: String = "image/jpeg",
        prefix: String = "ios-uploads"
    ) async throws -> URL {
        let fileName = UUID().uuidString + ".jpg"
        let path = "\(prefix)/\(fileName)"

        try await client.storage
            .from(AppConfig.storageBucket)
            .upload(
                path,
                data: data,
                options: FileOptions(contentType: contentType)
            )

        return try client.storage
            .from(AppConfig.storageBucket)
            .getPublicURL(path: path)
    }
}
